function tinyproxy
  if not command -q tinyproxy
    echo tinyproxy is required!
    return 1
  end
  set -l single_keywords \
    'User' \
    'Group' \
    'Port' \
    'Listen' \
    'Timeout' \
    'ErrorFile' \
    'DefaultErrorFile' \
    'StatHost' \
    'StatFile' \
    'LogFile' \
    'LogLevel' \
    'PidFile' \
    'Upstream' \
    'MaxClients' \
    'BasicAuth' \
    'AddHeader' \
    'Filter' \
    'FilterType' \
    'ConnectPort' \
    'ReverseBaseUrl'
  set -l multi_keywords \
    'Bind' \
    'Allow' \
    'Deny' \
    'Anonymous' \
    'ReversePath'
  set -l boolean_keywords \
    'BindSame' \
    'Syslog' \
    'XTinyproxy' \
    'ViaProxyName' \
    'DisableViaHeader' \
    'FilterUrls' \
    'FilterCaseSensitive' \
    'FilterDefaultDeny' \
    'ReverseOnly' \
    'ReverseMagic'
  set -l specs
  for keyword in $single_keywords $multi_keywords $boolean_keywords
    set -l modifier ''
    if contains $keyword $single_keywords
      set modifier '='
    else if contains $keyword $multi_keywords
      set modifier '=+'
    else if contains $keyword $boolean_keywords
      set modifier '=?'
    end
    set -a specs (string replace -r -a '(.)([A-Z])' '$1-$2' -- $keyword | string lower)$modifier
  end
  argparse -i \
    'd' \
    'c=' \
    'h' \
    'v' \
    $specs \
    -- $argv
  set -q _flag_h && command tinyproxy -h && return
  set -q _flag_v && command tinyproxy -v && return
  set -l conf (mktemp -t tinyproxy.conf)
  set -q _flag_c && test -f $_flag_c && cat $_flag_c >> $conf
  for keyword in $single_keywords $multi_keywords $boolean_keywords
    set -l flag _flag_(string replace -r -a '(.)([A-Z])' '$1_$2' -- $keyword | string lower)
    if set -q $flag
      set -l values $$flag
      if contains $keyword $boolean_keywords
        if test -z "$$flag"
          set values Yes
        else if contains (string lower $$flag) on yes
          set values (string sub -l 1 $$flag | string upper) (string sub -s 2 $$flag | string lower)
        end
      end
      for value in $values
        echo $keyword $value >> $conf
      end
    end
  end
  set flags -c $conf
  set -q _flag_d && set -a flags -d
  command tinyproxy $flags
end
