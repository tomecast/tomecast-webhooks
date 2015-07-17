from ruby:2.1

run \
    gem install bundler


# copy the application files to the image
workdir /srv/tomecast-webhooks
copy . /srv/tomecast-webhooks/
run bundle install --deployment



#finish up
EXPOSE 8080
CMD ["bash"]