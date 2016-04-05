#
# Routes file that exports route handlers for ease of testing.
#
User = require '../../models/user.coffee'

@index = (req, res, next) ->
  user_id = req.query.user_id

  if user_id?
    (user = new User(id: user_id)).fetch()
      .then ->
        res.render 'index', user: user
      .catch next
      .done()
  else
    res.render 'index'
