#Instructions
redirect port 80 requests to 8080  (which thin server is running on)
`iptables -t nat -A PREROUTING -p tcp --dport 80 -j REDIRECT --to-port 8080`

do a bundle install
`bundle install --path vendor/bundle`

start the server
`HOST="webhook.tomecast.com" bundle exec thin start -p 8080`

