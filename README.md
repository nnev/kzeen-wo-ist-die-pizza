# kzeen wo ist die Pizza?

## Development

#### Ruby
Use your favorite Ruby version hell manager to install a matching Ruby version. It should work with any, but we're targeting the one from Debian Testing, because that's what our server runs at.

Note: If you use asdf-vm, you might need to: `echo "legacy_version_file = yes" >> ~/.asdfrc`

#### Gems

This should do it:
```
# Install dependencies. We use the ones from the Dockerfile, which should be up to date for Debian.
$(grep -o 'apt-get install.*' ops/Dockerfile)
bundle install
```

Note that all gems are also vendor'd and should be updated by Bundler automatically when you change them.

#### Updating gems

```
bundle update                                       # or similar
bundle package                                      # ensure all gems are available
docker build -t kzeenpizza -f ops/Dockerfile .      # test everything works
git add Gemfile Gemfile.lock vendor/cache/*
git commit -m "Updated gems"
```

## Testing

You should be able to run/build using the included Dockerfile to run all tests:

```
docker build -t kzeenpizza -f ops/Dockerfile .
```

Otherwise, this should get you started:

```
export RAILS_ENV=test
bundle exec rails db:migrate
bundle exec rspec --exclude-pattern spec/features/*
bundle exec rails assets:precompile
```

##### Acceptance Tests / Headless Browsers
Acceptance tests are a bit more tricky. You'll either need Chrome/Chromium 61+ or Firefox 57+. The necessary drivers are installed through gems. To select which browser you'd like to run the tests with, and if to run in headless or net, edit the `spec/rails_helper.rb` file and edit `Capybara.javascript_driver`. Then you can run tests normally through `bundle exec rspec`.

## Deployment

See the example files in the `ops/` directory. Note that by default kzeenpizza listens on `localhost:10003`.

#### systemd

Using all default values:

```
adduser --home /var/www/pizza.noname-ev.de/ --disabled-login kzeenpizza
$(grep -o 'apt-get install.*' ops/Dockerfile)
cp ops/kzeenpizza.service /etc/systemd/system/
systemctl enable kzeenpizza.service
systemctl start kzeenpizza.service
cp ops/nginx_sample /etc/nginx/sites-available/kzeenpizza
ln -s /etc/nginx/sites-available/kzeenpizza /etc/nginx/sites-enabled/

```

#### Docker

There is currently no ready-to-use Dockerfile. The included one is for testing purposes only.
