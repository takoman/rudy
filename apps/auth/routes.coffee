#
# Routes file that exports route handlers for ease of testing.
#

{ parse } = require "url"

redirectBack = (req, res, next ) ->
  url = parse(req.get("Referrer") or "").path or "/"
  res.redirect url

@index = (req, res, next) ->
  res.render "index"

@afterLogin = (req, res, next) ->
  if req.xhr
    res.send { status: "success", message: "successfully logged in", user: req.user.toJSON() }
  else
    redirectBack req, res, next

@logout = (req, res, next) ->
  req.logout()
  redirectBack req, res, next
