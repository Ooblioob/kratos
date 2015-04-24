worker = require('pantheon-helpers').worker
_ = require('underscore')
follow = require('follow')
couch_utils = require('./couch_utils')
conf = require('./config')
validate = require('./validation')

orgs = conf.ORGS

handlers = {
  gh: require('./workers/gh').handlers,
}

# org workers
for org in orgs
  db = couch_utils.nano_system_user.use('org_' + org)
  worker.start_worker(db,
                      handlers,
                      validate._get_doc_type,
                      worker.get_plugin_handlers,
                     )


# _users worker
db = couch_utils.nano_system_user.use('_users')
worker.start_worker(db,
                    handlers,
                    validate._get_doc_type,
                    worker.get_plugin_handlers,
                   )
