function slackme
  set WEBHOOK 'put_webhook_here'

  docker run --rm \
    tailor/slack-cli \
    --webhook-url $WEBHOOK \
    # -c $CHANNEL \
    # "$argv[2..-1]"
    -c 'my_user_id_here' \
    "$argv"
end
