#
# Using ["The Twelve-Factor App"](http://12factor.net/) as a reference all
# environment configuration will live in environment variables. This file
# simply lays out all of those environment variables with sensible defaults
# for development.
#

module.exports =
  API_URL: 'http://localhost:3000'
  APP_NAME: 'rudy'
  APP_URL: 'http://localhost:5000'
  CDN_URL: 'replace-me'
  COOKIE_DOMAIN: null
  NODE_ENV: 'development'
  PORT: 5000
  S3_KEY: 'replace-me'
  S3_SECRET: 'replace-me'
  S3_BUCKET: 'replace-me'
  S3_UPLOAD_DIR: 'uploads'
  SESSION_SECRET: 'replace-me'
  SESSION_COOKIE_MAX_AGE: 31536000000
  SESSION_COOKIE_KEY: 'rudy.sess'
  PICKEE_ID: 'replace-me'
  PICKEE_SECRET: 'replace-me'

# Override any values with env variables if they exist.
# You can set JSON-y values for env variables as well such as "true" or
# "['foo']" and config will attempt to JSON.parse them into non-string types.
for key, val of module.exports
  val = (process.env[key] or val)
  module.exports[key] = try JSON.parse(val) catch then val

# Warn if this file is included client-side
alert("WARNING: Do not require config.coffee, please require('sharify').data instead.") if window?
