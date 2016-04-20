express = require 'express'
routes = require './routes'
{ loginPath, signupPath } = require('../../lib/middleware/pickee-passport').config

app = module.exports = express()
app.set 'views', __dirname + '/templates'
app.set 'view engine', 'jade'
app.get '/login', routes.index

# Use the same `loginPath` and `signupPath` as in pickee-passport. The
# passport will handle the actually login. If succeeded, request will be
# passed here and go on; if failed, it will go to the next error handler.
app.post loginPath, routes.afterLogin
app.post signupPath, routes.afterLogin

app.get '/logout', routes.logout
