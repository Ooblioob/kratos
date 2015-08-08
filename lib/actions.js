// Generated by CoffeeScript 1.9.2
(function() {
  var _, actionHandlers, utils;

  utils = require('pantheon-helpers').utils;

  _ = require('underscore');

  actionHandlers = {
    user: {
      'r+': function(user, action, actor) {
        var role;
        role = action.resource + '|' + action.role;
        return utils.insertInPlace(user.roles, role);
      },
      'r-': function(user, action, actor) {
        var role;
        role = action.resource + '|' + action.role;
        return utils.removeInPlace(user.roles, role);
      },
      'u+': function(user, action, actor) {
        return utils.insertInPlace(user.roles, 'kratos|enabled');
      },
      'u-': function(user, action, actor) {
        return user.roles = [];
      },
      'd+': function(user, action, actor) {
        var merge_target, path, value;
        path = ['data'].concat(action.path);
        value = action.data;
        if (!_.isObject(value) || _.isArray(value)) {
          throw new Error('value must be an object');
        }
        merge_target = utils.mkObjs(user, path, {});
        return _.extend(merge_target, value);
      }
    },
    team: {
      'u+': function(team, action, actor) {
        var members;
        members = utils.mkObjs(team.roles, [action.role, 'members'], []);
        return utils.insertInPlace(members, action.user);
      },
      'u-': function(team, action, actor) {
        var members;
        members = utils.mkObjs(team.roles, [action.role, 'members'], []);
        return utils.removeInPlace(members, action.user);
      },
      'a+': function(team, action, actor) {
        var assets;
        action.asset.id = action.id;
        assets = utils.mkObjs(team.rsrcs, [action.resource, 'assets'], []);
        return utils.insertInPlaceById(assets, action.asset);
      },
      'a-': function(team, action, actor) {
        var assets, removed_asset;
        assets = utils.mkObjs(team.rsrcs, [action.resource, 'assets'], []);
        removed_asset = utils.removeInPlaceById(assets, action.asset);
        if (removed_asset) {
          return action.asset = removed_asset;
        }
      }
    },
    create: {
      'u+': function(user, action, actor) {
        return _.extend(user, action.record, {
          _id: 'org.couchdb.user:' + user._id,
          type: 'user',
          name: user._id
        });
      },
      't+': function(team, action, actor) {
        return _.extend(team, {
          _id: 'team_' + action.name,
          name: action.name,
          rsrcs: {},
          roles: {},
          enforce: []
        });
      }
    }
  };

  module.exports = actionHandlers;

}).call(this);