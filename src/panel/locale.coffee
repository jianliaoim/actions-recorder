
enLocales =
  commit: 'commit'
  reset: 'reset'
  discard: 'discard'
  run: 'run'

zhLocales =
  commit: '合并'
  reset: '重置'
  discard: '清除'
  run: '运行'

exports.get (key, lang) ->
  switch lang
    when 'zh' then zhLocale[key] or "{{#{key}}}"
    when 'en' then enLocale[key] or "{{#{key}}}"
    else "{{#{key}}}"
