# Rudy
Develop [![Circle CI](https://circleci.com/gh/takoman/rudy/tree/develop.svg?style=svg&circle-token=49e9c48ef74752b5e3bf2e33f514da8a14d0b8c8)](https://circleci.com/gh/takoman/rudy/tree/develop), Master [![Circle CI](https://circleci.com/gh/takoman/rudy/tree/master.svg?style=svg&circle-token=49e9c48ef74752b5e3bf2e33f514da8a14d0b8c8)](https://circleci.com/gh/takoman/rudy/tree/master)

Meta
---

* __State:__ development
* __Production:__ [http://mypickee.com/](http://mypickee.com/) | [Heroku](https://dashboard.heroku.com/apps/rudy-production/resources)
* __Staging:__ [http://staging.mypickee.com/](http://staging.mypickee.com/) | [Heroku](https://dashboard.heroku.com/apps/rudy-staging/resources)
* __Github:__ [https://github.com/takoman/rudy/](https://github.com/takoman/rudy/)
* __CI:__ [Circle CI](https://circleci.com/gh/takoman/rudy); merged PRs to takoman/rudy#develop are automatically deployed to staging; production is automatically deployed after a successful build by circleci when a PR from develop to master is merged.
* __Point People:__ [@starsirius](https://github.com/starsirius), [@beamjet](https://github.com/beamjet)

Set-Up
---

- Install [NVM](https://github.com/creationix/nvm)
- Install Node 5
```
nvm install 5
nvm alias default 5
```
- Fork Rudy to your Github account in the Github UI.
- Clone your repo locally (substitute your Github username).
```
git clone git@github.com:starsirius/rudy.git
```
- Install node modules
```
cd rudy
npm install
```
- Get Santa access tokens from your local Santa console
```ruby
application = ClientApplication.create!(name: 'Rudy', access_granted: true)
puts "PICKEE_ID=#{application.app_id}\nPICKEE_SECRET=#{application.app_secret}"
```
- Create a .env file using the example and paste in `PICKEE_ID`, `PICKEE_SECRET` and other sensitive configuration.
```
cp .env.example .env
# Then modify the environment variables
```
- Start Rudy pointing to the local [Santa](https://github.com/takoman/santa) API
```
make s
```
- Rudy should now be running at [http://localhost:5000/](http://localhost:5000/)

Additional docs
---

You can find additional documentation about Rudy (deployments et c) in this repository's /doc directory.

&copy; copyright 2014 by [starsirius](https://github.com/starsirius) and [beamjet](https://github.com/beamjet).
