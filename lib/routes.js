// Generated by CoffeeScript 1.9.2
(function() {
  var api, auditRoutes, couchUtils, express, resourcePlugins, teams, user, users, utils, validation;

  api = require('./api');

  teams = api.teams, users = api.users, user = api.user;

  utils = require('./utils');

  auditRoutes = require('pantheon-helpers').auditRoutes;

  couchUtils = require('./couch_utils');

  validation = require('./validation');

  express = require('express');

  resourcePlugins = utils.getPlugins();

  module.exports = function(app) {
    var i, len, plugin, pluginRouter;
    app.get('/kratos/orgs/:orgId/teams/', teams.handleGetTeams);
    app.route('/kratos/orgs/:orgId/teams/:teamId').get(teams.handleGetTeam).put(teams.handleCreateTeam);
    app.get('/kratos/orgs/:orgId/teams/:teamId/details', teams.handleGetTeamDetails);
    app.route('/kratos/orgs/:orgId/teams/:teamId/roles/:role/:userId').put(teams.handleAddMember)["delete"](teams.handleRemoveMember);
    app.post('/kratos/orgs/:orgId/teams/:teamId/resources/:resource/', teams.handleAddAsset);
    app["delete"]('/kratos/orgs/:orgId/teams/:teamId/resources/:resource/:assetId/', teams.handleRemoveAsset);
    for (i = 0, len = resourcePlugins.length; i < len; i++) {
      plugin = resourcePlugins[i];
      if (plugin.proxy) {
        pluginRouter = express.Router({
          mergeParams: true
        });
        plugin.proxy(pluginRouter, api, validation, couchUtils);
        app.use('/kratos/orgs/:orgId/teams/:teamId/resources/' + plugin.name, pluginRouter);
      }
    }
    app.route('/kratos/users').get(users.handleGetUsers).post(users.handleCreateUser);
    app.route('/kratos/users/:userId').get(users.handleGetUser).put(users.handleReactivateUser)["delete"](users.handleDeactivateUser);
    app.route('/kratos/users/:userId/roles/:resource/:role').put(users.handleAddRole)["delete"](users.handleRemoveRole);
    app.put('/kratos/users/:userId/data/:path?*', users.handleAddData);
    app.get('/kratos/user', user.handleGetUser);
    return auditRoutes(app, ['_users', 'org_devdesign'], couchUtils, '/kratos');
  };

}).call(this);
