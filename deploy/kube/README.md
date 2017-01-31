# few words
in order to push elasticsearch db to beta / prod you will need persistent volumes and proper tags on nodes
```
kubectl get no
NAME                        LABELS                                                                                  STATUS     AGE
ip-172-20-0-109.erento.io   datacenter=eu-west-1,env=prod,kubernetes.io/hostname=kubenode1-prod.erento.io,zone=a    Ready      32m
ip-172-20-1-51.erento.io    datacenter=eu-west-1,env=prod,kubernetes.io/hostname=kubenode21-prod.erento.io,zone=b   Ready      32m
ip-172-20-2-139.erento.io   datacenter=eu-west-1,env=prod,kubernetes.io/hostname=kubenode41-prod.erento.io,zone=c   Ready      32m

kubetcl get pv
NAME                LABELS                      CAPACITY   ACCESSMODES   STATUS      CLAIM     REASON    AGE
db-search-a1-prod   app=search,role=db,zone=a   10Gi       RWO           Available                       4d
db-search-b1-prod   app=search,role=db,zone=b   10Gi       RWO           Available                       4d
db-search-c1-prod   app=search,role=db,zone=c   10Gi       RWO           Available                       4d
```

* on nodes you will need label zone
* on volumes zone app and role
* in 05-search-db.json you will find that RC have app and role that corresponds to volume app and role from the k8aws script will generate runtime RC list file that will contain RC templates for app, role and zone

# beta / prod setup
example for beta
```
kubectl -f 01-search-master-service.json -f 02-search-client-service.json \
-f 03-search-master-controller.json -f 04-search-client-controller.json

k8aws 05-search-db.json $(host kubemaster1-beta|awk '{print $4}'):8080 | kubectl -f -
```
