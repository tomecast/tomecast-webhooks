#Instructions
redirect port 80 requests to 8080  (which thin server is running on)
`iptables -t nat -A PREROUTING -p tcp --dport 80 -j REDIRECT --to-port 8080`

do a bundle install
`bundle install --path vendor/bundle`

start the server
`REDIS_SERVER_URL="" HOST="webhook.tomecast.com" bundle exec thin start -p 8080 -d`


docker run \
    --name tomecast-webhooks \
    -p 80:8080 \
    --restart "on-failure:5" \
    --env REDIS_SERVER_URL="redis://" \
    --env HOST="webhook.tomecast.com" \
    -d \
    analogj/tomecast-webhooks \
    bundle exec thin start -p 8080