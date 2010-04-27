def niconico(video_id)
  str = <<EOF
<script type="text/javascript" src="http://www.nicovideo.jp/thumb_watch/#{video_id}?w=485&h=385" charset="utf-8"></script>
EOF

  return str
end

