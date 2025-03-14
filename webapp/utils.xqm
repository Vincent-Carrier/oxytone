module namespace u = "oxytone/utils";

declare function u:cached($body) {
  if (db:option('debug'))
    then $body
    else ($body, web:response-header({
      'Cache-Control': 'max-age=3600,public'
    }))
};
