function tinyproxy
  if not command --query tinyproxy
    echo tinyproxy is required!
    return 1
  end
  set --local single_keywords \
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
  set --local multi_keywords \
    'Bind' \
    'Allow' \
    'Deny' \
    'Anonymous' \
    'ReversePath'
  set --local boolean_keywords \
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
  set --local specs
  for keyword in $single_keywords $multi_keywords $boolean_keywords
    set --local modifier ''
    if contains $keyword $single_keywords
      set modifier '='
    else if contains $keyword $multi_keywords
      set modifier '=+'
    else if contains $keyword $boolean_keywords
      set modifier '=?'
    end
    set --append specs (string replace --regex --all '(.)([A-Z])' '$1-$2' -- $keyword | string lower)$modifier
  end
  argparse --ignore-unknown \
    'd' \
    'c=' \
    'h' \
    'v' \
    $specs \
    -- $argv
  set --query _flag_h && command tinyproxy -h && return
  set --query _flag_v && command tinyproxy -v && return
  set --local conf (mktemp -t tinyproxy.conf)
  set --query _flag_c && test -f $_flag_c && cat $_flag_c >> $conf
  for keyword in $single_keywords $multi_keywords $boolean_keywords
    set --local flag _flag_(string replace --regex --all '(.)([A-Z])' '$1_$2' -- $keyword | string lower)
    if set --query $flag
      set --local values $$flag
      if contains $keyword $boolean_keywords
        if test -z "$$flag"
          set values Yes
        else if contains (string lower $$flag) on yes
          set values (string sub --length 1 $$flag | string upper) (string sub --start 2 $$flag | string lower)
        end
      end
      for value in $values
        echo $keyword $value >> $conf
      end
    end
  end
  set flags -c $conf
  set --query _flag_d && set --append flags -d
  command tinyproxy $flags
end
