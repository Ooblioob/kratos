// Generated by CoffeeScript 1.9.2
(function() {
  var _, dd, helpers, shared;

  _ = require('underscore');

  shared = require('./shared');

  helpers = require('pantheon-helpers').design_docs.helpers(shared);

  dd = {
    views: {
      by_resource_id: {
        map: function(doc) {
          var ref, resource, resource_id, resource_name, results;
          ref = doc.rsrcs;
          results = [];
          for (resource_name in ref) {
            resource = ref[resource_name];
            resource_id = resource.id;
            if (resource_id) {
              results.push(emit([resource_name, resource_id], doc.name));
            } else {
              results.push(void 0);
            }
          }
          return results;
        }
      },
      by_resource_username: {
        map: function(doc) {
          var auth, ref, resource, resource_name, resource_username, results;
          auth = require('views/lib/auth');
          if (!auth.is_active_user(doc)) {
            return;
          }
          ref = doc.rsrcs;
          results = [];
          for (resource_name in ref) {
            resource = ref[resource_name];
            resource_username = resource.username;
            if (resource_username) {
              results.push(emit([resource_name, resource_username], doc.name));
            } else {
              results.push(void 0);
            }
          }
          return results;
        }
      },
      by_username: {
        map: function(doc) {
          var auth;
          auth = require('views/lib/auth');
          if (auth.is_active_user(doc) && doc.data.username) {
            return emit(doc.data.username);
          }
        }
      },
      by_name: {
        map: function(doc) {
          var auth;
          auth = require('views/lib/auth');
          if (auth._is_user(doc)) {
            return emit([auth.is_active_user(doc), doc.name]);
          }
        }
      },
      by_auth: {
        map: function(doc) {
          var auth, i, len, out, ref, results, role;
          auth = require('views/lib/auth');
          if (!auth.is_active_user(doc)) {
            return;
          }
          ref = doc.roles;
          results = [];
          for (i = 0, len = ref.length; i < len; i++) {
            role = ref[i];
            out = role.split('|');
            out.push(doc.name);
            results.push(emit(out));
          }
          return results;
        }
      },
      contractors: {
        map: function(doc) {
          var auth, ref;
          auth = require('views/lib/auth');
          if (auth.is_active_user(doc)) {
            return emit(((ref = doc.data) != null ? ref.contractor : void 0) || false, doc.data.username);
          }
        }
      }
    },
    lists: {
      get_users: function(header, req) {
        return helpers.lists.get_prepped_of_type(getRow, start, send, 'user', header, req);
      },
      get_user: function(header, req) {
        return helpers.lists.get_first_prepped(getRow, start, send, header, req);
      }
    },
    shows: {
      get_user: helpers.shows.get_prepped
    },
    rewrites: [
      {
        from: "/users/:user_id",
        to: "/_show/get_user/:user_id",
        query: {}
      }
    ]
  };

  module.exports = dd;

}).call(this);
