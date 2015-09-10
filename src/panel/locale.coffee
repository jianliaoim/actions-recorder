
enLocales =
  mergeBefore: 'merge before'
  clearAfter: 'clear after'
  reset: 'reset run'
  commit: 'commit run'
  run: 'run'

zhLocales =
  mergeBefore: '合并前面的操作'
  clearAfter: '清除后面的操作'
  commit: '合并运行'
  reset: '重置运行'
  run: '运行'

exports.get = (key, lang) ->
  switch lang
    when 'zh' then zhLocales[key] or "{{#{key}}}"
    when 'en' then enLocales[key] or "{{#{key}}}"
    else "{{#{key}}}"
