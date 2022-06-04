      #!/bin/bash
      export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/root/bin
      str1="0/1"
      input0="0"
      #kubectl get -n vault secrets vault-secret  -o "jsonpath={.data.VAULT_UNSEAL_KEY}" | base64 -d > VAULT_DECODED_KEY
      VAULT_DECODED_KEY=`kubectl get -n vault secrets vault-secret  -o "jsonpath={.data.VAULT_UNSEAL_KEY}" | base64 -d`
      kubectl get -n vault pod | grep vault-"$input0"
      if [ "$?" = 0 ]; then
        status=`kubectl get -n vault pod | grep vault-0 | awk '{print $2}'`
        echo $status
        if [ "$status" = "$str1" ]; then
                  kubectl exec -n vault vault-"$input0" -- vault operator unseal $VAULT_DECODED_KEY
                  sleep 10
        else
             echo "false"
        fi
      fi
