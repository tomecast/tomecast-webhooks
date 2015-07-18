from ruby:2.1

run \
    gem install bundler


# copy the application files to the image
workdir /srv/tomecast-webhooks
copy . /srv/tomecast-webhooks/
run bundle install --path vendor/bundle



#finish up
EXPOSE 8080
CMD ["bundle exec thin start -p 8080"]