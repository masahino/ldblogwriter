def youtube(video_id)
  str = <<EOF
<object width="425" height="350">
<param name="movie" value="http://www.youtube.com/v/#{video_id}">
</param>
<embed src="http://www.youtube.com/v/#{video_id}" type="application/x-shockwave-flash" width="425" height="350">
</embed>
</object> 
EOF

  return str
end
