let Kubernetes/Deployment =
      ../../deps/k8s/schemas/io.k8s.api.apps.v1.Deployment.dhall

let Kubernetes/List = ../../util/kubernetes-list.dhall

let Kubernetes/Service = ../../deps/k8s/schemas/io.k8s.api.core.v1.Service.dhall

let Kubernetes/PersistentVolumeClaim =
      ../../deps/k8s/schemas/io.k8s.api.core.v1.PersistentVolumeClaim.dhall

let Kubernetes/TypesUnion = ../../deps/k8s/typesUnion.dhall

let Configuration/global = ../../configuration/global.dhall

let component =
      { BundleManager :
          { Deployment : Kubernetes/Deployment.Type
          , Service : Kubernetes/Service.Type
          , PersistentVolumeClaim : Kubernetes/PersistentVolumeClaim.Type
          }
      , Worker :
          { Deployment : Kubernetes/Deployment.Type
          , Service : Kubernetes/Service.Type
          }
      }

let BundleManager/PersistentVolumeClaim/generate =
      λ(c : Configuration/global.Type) →
        let persistentVolumeClaim =
              Kubernetes/PersistentVolumeClaim::{
              , apiVersion = "v1"
              , kind = "PersistentVolumeClaim"
              , metadata =
                { annotations = None (List { mapKey : Text, mapValue : Text })
                , clusterName = None Text
                , creationTimestamp = None Text
                , deletionGracePeriodSeconds = None Natural
                , deletionTimestamp = None Text
                , finalizers = None (List Text)
                , generateName = None Text
                , generation = None Natural
                , labels = Some
                    ( toMap
                        { sourcegraph-resource-requires = "no-cluster-admin"
                        , deploy = "sourcegraph"
                        }
                    )
                , managedFields =
                    None
                      ( List
                          { apiVersion : Text
                          , fieldsType : Optional Text
                          , fieldsV1 :
                              Optional (List { mapKey : Text, mapValue : Text })
                          , manager : Optional Text
                          , operation : Optional Text
                          , time : Optional Text
                          }
                      )
                , name = Some "bundle-manager"
                , namespace = None Text
                , ownerReferences =
                    None
                      ( List
                          { apiVersion : Text
                          , blockOwnerDeletion : Optional Bool
                          , controller : Optional Bool
                          , kind : Text
                          , name : Text
                          , uid : Text
                          }
                      )
                , resourceVersion = None Text
                , selfLink = None Text
                , uid = None Text
                }
              , spec = Some
                { accessModes = Some [ "ReadWriteOnce" ]
                , dataSource =
                    None { apiGroup : Optional Text, kind : Text, name : Text }
                , resources = Some
                  { limits = None (List { mapKey : Text, mapValue : Text })
                  , requests = Some (toMap { storage = "200Gi" })
                  }
                , selector =
                    None
                      { matchExpressions :
                          Optional
                            ( List
                                { key : Text
                                , operator : Text
                                , values : Optional (List Text)
                                }
                            )
                      , matchLabels :
                          Optional (List { mapKey : Text, mapValue : Text })
                      }
                , storageClassName = Some "sourcegraph"
                , volumeMode = None Text
                , volumeName = None Text
                }
              , status =
                  None
                    { accessModes : Optional (List Text)
                    , capacity :
                        Optional (List { mapKey : Text, mapValue : Text })
                    , conditions :
                        Optional
                          ( List
                              { lastProbeTime : Optional Text
                              , lastTransitionTime : Optional Text
                              , message : Optional Text
                              , reason : Optional Text
                              , status : Text
                              , type : Text
                              }
                          )
                    , phase : Optional Text
                    }
              }

        in  persistentVolumeClaim

let BundleManager/Service/generate =
      λ(c : Configuration/global.Type) →
        let service =
              Kubernetes/Service::{
              , apiVersion = "v1"
              , kind = "Service"
              , metadata =
                { annotations = Some
                    ( toMap
                        { `sourcegraph.prometheus/scrape` = "true"
                        , `prometheus.io/port` = "6060"
                        }
                    )
                , clusterName = None Text
                , creationTimestamp = None Text
                , deletionGracePeriodSeconds = None Natural
                , deletionTimestamp = None Text
                , finalizers = None (List Text)
                , generateName = None Text
                , generation = None Natural
                , labels = Some
                    ( toMap
                        { sourcegraph-resource-requires = "no-cluster-admin"
                        , app = "precise-code-intel-bundle-manager"
                        , deploy = "sourcegraph"
                        }
                    )
                , managedFields =
                    None
                      ( List
                          { apiVersion : Text
                          , fieldsType : Optional Text
                          , fieldsV1 :
                              Optional (List { mapKey : Text, mapValue : Text })
                          , manager : Optional Text
                          , operation : Optional Text
                          , time : Optional Text
                          }
                      )
                , name = Some "precise-code-intel-bundle-manager"
                , namespace = None Text
                , ownerReferences =
                    None
                      ( List
                          { apiVersion : Text
                          , blockOwnerDeletion : Optional Bool
                          , controller : Optional Bool
                          , kind : Text
                          , name : Text
                          , uid : Text
                          }
                      )
                , resourceVersion = None Text
                , selfLink = None Text
                , uid = None Text
                }
              , spec = Some
                { clusterIP = None Text
                , externalIPs = None (List Text)
                , externalName = None Text
                , externalTrafficPolicy = None Text
                , healthCheckNodePort = None Natural
                , ipFamily = None Text
                , loadBalancerIP = None Text
                , loadBalancerSourceRanges = None (List Text)
                , ports = Some
                  [ { name = Some "http"
                    , nodePort = None Natural
                    , port = 3187
                    , protocol = None Text
                    , targetPort = Some
                        (< Int : Natural | String : Text >.String "http")
                    }
                  , { name = Some "debug"
                    , nodePort = None Natural
                    , port = 6060
                    , protocol = None Text
                    , targetPort = Some
                        (< Int : Natural | String : Text >.String "debug")
                    }
                  ]
                , publishNotReadyAddresses = None Bool
                , selector = Some
                    (toMap { app = "precise-code-intel-bundle-manager" })
                , sessionAffinity = None Text
                , sessionAffinityConfig =
                    None
                      { clientIP :
                          Optional { timeoutSeconds : Optional Natural }
                      }
                , topologyKeys = None (List Text)
                , type = Some "ClusterIP"
                }
              , status =
                  None
                    { loadBalancer :
                        Optional
                          { ingress :
                              Optional
                                ( List
                                    { hostname : Optional Text
                                    , ip : Optional Text
                                    }
                                )
                          }
                    }
              }

        in  service

let BundleManager/Deployment/generate =
      λ(c : Configuration/global.Type) →
        let deployment =
              Kubernetes/Deployment::{
              , apiVersion = "apps/v1"
              , kind = "Deployment"
              , metadata =
                { annotations = Some
                    ( toMap
                        { description =
                            "Stores and manages precise code intelligence bundles."
                        }
                    )
                , clusterName = None Text
                , creationTimestamp = None Text
                , deletionGracePeriodSeconds = None Natural
                , deletionTimestamp = None Text
                , finalizers = None (List Text)
                , generateName = None Text
                , generation = None Natural
                , labels = Some
                    ( toMap
                        { sourcegraph-resource-requires = "no-cluster-admin"
                        , deploy = "sourcegraph"
                        }
                    )
                , managedFields =
                    None
                      ( List
                          { apiVersion : Text
                          , fieldsType : Optional Text
                          , fieldsV1 :
                              Optional (List { mapKey : Text, mapValue : Text })
                          , manager : Optional Text
                          , operation : Optional Text
                          , time : Optional Text
                          }
                      )
                , name = Some "precise-code-intel-bundle-manager"
                , namespace = None Text
                , ownerReferences =
                    None
                      ( List
                          { apiVersion : Text
                          , blockOwnerDeletion : Optional Bool
                          , controller : Optional Bool
                          , kind : Text
                          , name : Text
                          , uid : Text
                          }
                      )
                , resourceVersion = None Text
                , selfLink = None Text
                , uid = None Text
                }
              , spec = Some
                { minReadySeconds = Some 10
                , paused = None Bool
                , progressDeadlineSeconds = None Natural
                , replicas = Some 1
                , revisionHistoryLimit = Some 10
                , selector =
                  { matchExpressions =
                      None
                        ( List
                            { key : Text
                            , operator : Text
                            , values : Optional (List Text)
                            }
                        )
                  , matchLabels = Some
                      (toMap { app = "precise-code-intel-bundle-manager" })
                  }
                , strategy = Some
                  { rollingUpdate =
                      None
                        { maxSurge : Optional < Int : Natural | String : Text >
                        , maxUnavailable :
                            Optional < Int : Natural | String : Text >
                        }
                  , type = Some "Recreate"
                  }
                , template =
                  { metadata =
                    { annotations =
                        None (List { mapKey : Text, mapValue : Text })
                    , clusterName = None Text
                    , creationTimestamp = None Text
                    , deletionGracePeriodSeconds = None Natural
                    , deletionTimestamp = None Text
                    , finalizers = None (List Text)
                    , generateName = None Text
                    , generation = None Natural
                    , labels = Some
                        ( toMap
                            { app = "precise-code-intel-bundle-manager"
                            , deploy = "sourcegraph"
                            }
                        )
                    , managedFields =
                        None
                          ( List
                              { apiVersion : Text
                              , fieldsType : Optional Text
                              , fieldsV1 :
                                  Optional
                                    (List { mapKey : Text, mapValue : Text })
                              , manager : Optional Text
                              , operation : Optional Text
                              , time : Optional Text
                              }
                          )
                    , name = None Text
                    , namespace = None Text
                    , ownerReferences =
                        None
                          ( List
                              { apiVersion : Text
                              , blockOwnerDeletion : Optional Bool
                              , controller : Optional Bool
                              , kind : Text
                              , name : Text
                              , uid : Text
                              }
                          )
                    , resourceVersion = None Text
                    , selfLink = None Text
                    , uid = None Text
                    }
                  , spec = Some
                    { activeDeadlineSeconds = None Natural
                    , affinity =
                        None
                          { nodeAffinity :
                              Optional
                                { preferredDuringSchedulingIgnoredDuringExecution :
                                    Optional
                                      ( List
                                          { preference :
                                              { matchExpressions :
                                                  Optional
                                                    ( List
                                                        { key : Text
                                                        , operator : Text
                                                        , values :
                                                            Optional (List Text)
                                                        }
                                                    )
                                              , matchFields :
                                                  Optional
                                                    ( List
                                                        { key : Text
                                                        , operator : Text
                                                        , values :
                                                            Optional (List Text)
                                                        }
                                                    )
                                              }
                                          , weight : Natural
                                          }
                                      )
                                , requiredDuringSchedulingIgnoredDuringExecution :
                                    Optional
                                      { nodeSelectorTerms :
                                          List
                                            { matchExpressions :
                                                Optional
                                                  ( List
                                                      { key : Text
                                                      , operator : Text
                                                      , values :
                                                          Optional (List Text)
                                                      }
                                                  )
                                            , matchFields :
                                                Optional
                                                  ( List
                                                      { key : Text
                                                      , operator : Text
                                                      , values :
                                                          Optional (List Text)
                                                      }
                                                  )
                                            }
                                      }
                                }
                          , podAffinity :
                              Optional
                                { preferredDuringSchedulingIgnoredDuringExecution :
                                    Optional
                                      ( List
                                          { podAffinityTerm :
                                              { labelSelector :
                                                  Optional
                                                    { matchExpressions :
                                                        Optional
                                                          ( List
                                                              { key : Text
                                                              , operator : Text
                                                              , values :
                                                                  Optional
                                                                    (List Text)
                                                              }
                                                          )
                                                    , matchLabels :
                                                        Optional
                                                          ( List
                                                              { mapKey : Text
                                                              , mapValue : Text
                                                              }
                                                          )
                                                    }
                                              , namespaces :
                                                  Optional (List Text)
                                              , topologyKey : Text
                                              }
                                          , weight : Natural
                                          }
                                      )
                                , requiredDuringSchedulingIgnoredDuringExecution :
                                    Optional
                                      ( List
                                          { labelSelector :
                                              Optional
                                                { matchExpressions :
                                                    Optional
                                                      ( List
                                                          { key : Text
                                                          , operator : Text
                                                          , values :
                                                              Optional
                                                                (List Text)
                                                          }
                                                      )
                                                , matchLabels :
                                                    Optional
                                                      ( List
                                                          { mapKey : Text
                                                          , mapValue : Text
                                                          }
                                                      )
                                                }
                                          , namespaces : Optional (List Text)
                                          , topologyKey : Text
                                          }
                                      )
                                }
                          , podAntiAffinity :
                              Optional
                                { preferredDuringSchedulingIgnoredDuringExecution :
                                    Optional
                                      ( List
                                          { podAffinityTerm :
                                              { labelSelector :
                                                  Optional
                                                    { matchExpressions :
                                                        Optional
                                                          ( List
                                                              { key : Text
                                                              , operator : Text
                                                              , values :
                                                                  Optional
                                                                    (List Text)
                                                              }
                                                          )
                                                    , matchLabels :
                                                        Optional
                                                          ( List
                                                              { mapKey : Text
                                                              , mapValue : Text
                                                              }
                                                          )
                                                    }
                                              , namespaces :
                                                  Optional (List Text)
                                              , topologyKey : Text
                                              }
                                          , weight : Natural
                                          }
                                      )
                                , requiredDuringSchedulingIgnoredDuringExecution :
                                    Optional
                                      ( List
                                          { labelSelector :
                                              Optional
                                                { matchExpressions :
                                                    Optional
                                                      ( List
                                                          { key : Text
                                                          , operator : Text
                                                          , values :
                                                              Optional
                                                                (List Text)
                                                          }
                                                      )
                                                , matchLabels :
                                                    Optional
                                                      ( List
                                                          { mapKey : Text
                                                          , mapValue : Text
                                                          }
                                                      )
                                                }
                                          , namespaces : Optional (List Text)
                                          , topologyKey : Text
                                          }
                                      )
                                }
                          }
                    , automountServiceAccountToken = None Bool
                    , containers =
                      [ { args = None (List Text)
                        , command = None (List Text)
                        , env = Some
                          [ { name = "PRECISE_CODE_INTEL_BUNDLE_DIR"
                            , value = Some "/lsif-storage"
                            , valueFrom =
                                None
                                  { configMapKeyRef :
                                      Optional
                                        { key : Text
                                        , name : Optional Text
                                        , optional : Optional Bool
                                        }
                                  , fieldRef :
                                      Optional
                                        { apiVersion : Optional Text
                                        , fieldPath : Text
                                        }
                                  , resourceFieldRef :
                                      Optional
                                        { containerName : Optional Text
                                        , divisor : Optional Text
                                        , resource : Text
                                        }
                                  , secretKeyRef :
                                      Optional
                                        { key : Text
                                        , name : Optional Text
                                        , optional : Optional Bool
                                        }
                                  }
                            }
                          , { name = "POD_NAME"
                            , value = None Text
                            , valueFrom = Some
                              { configMapKeyRef =
                                  None
                                    { key : Text
                                    , name : Optional Text
                                    , optional : Optional Bool
                                    }
                              , fieldRef = Some
                                { apiVersion = None Text
                                , fieldPath = "metadata.name"
                                }
                              , resourceFieldRef =
                                  None
                                    { containerName : Optional Text
                                    , divisor : Optional Text
                                    , resource : Text
                                    }
                              , secretKeyRef =
                                  None
                                    { key : Text
                                    , name : Optional Text
                                    , optional : Optional Bool
                                    }
                              }
                            }
                          ]
                        , envFrom =
                            None
                              ( List
                                  { configMapRef :
                                      Optional
                                        { name : Optional Text
                                        , optional : Optional Bool
                                        }
                                  , prefix : Optional Text
                                  , secretRef :
                                      Optional
                                        { name : Optional Text
                                        , optional : Optional Bool
                                        }
                                  }
                              )
                        , image = Some
                            "index.docker.io/sourcegraph/precise-code-intel-bundle-manager:3.16.1@sha256:57cfbb6f7abca375ff0b24031383c737b4723b7fbe6d34d1b85efb24ac13463f"
                        , imagePullPolicy = None Text
                        , lifecycle =
                            None
                              { postStart :
                                  Optional
                                    { exec :
                                        Optional
                                          { command : Optional (List Text) }
                                    , httpGet :
                                        Optional
                                          { host : Optional Text
                                          , httpHeaders :
                                              Optional
                                                ( List
                                                    { name : Text
                                                    , value : Text
                                                    }
                                                )
                                          , path : Optional Text
                                          , port :
                                              < Int : Natural | String : Text >
                                          , scheme : Optional Text
                                          }
                                    , tcpSocket :
                                        Optional
                                          { host : Optional Text
                                          , port :
                                              < Int : Natural | String : Text >
                                          }
                                    }
                              , preStop :
                                  Optional
                                    { exec :
                                        Optional
                                          { command : Optional (List Text) }
                                    , httpGet :
                                        Optional
                                          { host : Optional Text
                                          , httpHeaders :
                                              Optional
                                                ( List
                                                    { name : Text
                                                    , value : Text
                                                    }
                                                )
                                          , path : Optional Text
                                          , port :
                                              < Int : Natural | String : Text >
                                          , scheme : Optional Text
                                          }
                                    , tcpSocket :
                                        Optional
                                          { host : Optional Text
                                          , port :
                                              < Int : Natural | String : Text >
                                          }
                                    }
                              }
                        , livenessProbe = Some
                          { exec = None { command : Optional (List Text) }
                          , failureThreshold = None Natural
                          , httpGet = Some
                            { host = None Text
                            , httpHeaders =
                                None (List { name : Text, value : Text })
                            , path = Some "/healthz"
                            , port =
                                < Int : Natural | String : Text >.String "http"
                            , scheme = Some "HTTP"
                            }
                          , initialDelaySeconds = Some 60
                          , periodSeconds = None Natural
                          , successThreshold = None Natural
                          , tcpSocket =
                              None
                                { host : Optional Text
                                , port : < Int : Natural | String : Text >
                                }
                          , timeoutSeconds = Some 5
                          }
                        , name = "precise-code-intel-bundle-manager"
                        , ports = Some
                          [ { containerPort = 3187
                            , hostIP = None Text
                            , hostPort = None Natural
                            , name = Some "http"
                            , protocol = None Text
                            }
                          , { containerPort = 6060
                            , hostIP = None Text
                            , hostPort = None Natural
                            , name = Some "debug"
                            , protocol = None Text
                            }
                          ]
                        , readinessProbe = Some
                          { exec = None { command : Optional (List Text) }
                          , failureThreshold = None Natural
                          , httpGet = Some
                            { host = None Text
                            , httpHeaders =
                                None (List { name : Text, value : Text })
                            , path = Some "/healthz"
                            , port =
                                < Int : Natural | String : Text >.String "http"
                            , scheme = Some "HTTP"
                            }
                          , initialDelaySeconds = None Natural
                          , periodSeconds = Some 5
                          , successThreshold = None Natural
                          , tcpSocket =
                              None
                                { host : Optional Text
                                , port : < Int : Natural | String : Text >
                                }
                          , timeoutSeconds = Some 5
                          }
                        , resources = Some
                          { limits = Some (toMap { memory = "2G", cpu = "2" })
                          , requests = Some
                              (toMap { memory = "500M", cpu = "500m" })
                          }
                        , securityContext =
                            None
                              { allowPrivilegeEscalation : Optional Bool
                              , capabilities :
                                  Optional
                                    { add : Optional (List Text)
                                    , drop : Optional (List Text)
                                    }
                              , privileged : Optional Bool
                              , procMount : Optional Text
                              , readOnlyRootFilesystem : Optional Bool
                              , runAsGroup : Optional Natural
                              , runAsNonRoot : Optional Bool
                              , runAsUser : Optional Natural
                              , seLinuxOptions :
                                  Optional
                                    { level : Optional Text
                                    , role : Optional Text
                                    , type : Optional Text
                                    , user : Optional Text
                                    }
                              , windowsOptions :
                                  Optional
                                    { gmsaCredentialSpec : Optional Text
                                    , gmsaCredentialSpecName : Optional Text
                                    , runAsUserName : Optional Text
                                    }
                              }
                        , startupProbe =
                            None
                              { exec :
                                  Optional { command : Optional (List Text) }
                              , failureThreshold : Optional Natural
                              , httpGet :
                                  Optional
                                    { host : Optional Text
                                    , httpHeaders :
                                        Optional
                                          (List { name : Text, value : Text })
                                    , path : Optional Text
                                    , port : < Int : Natural | String : Text >
                                    , scheme : Optional Text
                                    }
                              , initialDelaySeconds : Optional Natural
                              , periodSeconds : Optional Natural
                              , successThreshold : Optional Natural
                              , tcpSocket :
                                  Optional
                                    { host : Optional Text
                                    , port : < Int : Natural | String : Text >
                                    }
                              , timeoutSeconds : Optional Natural
                              }
                        , stdin = None Bool
                        , stdinOnce = None Bool
                        , terminationMessagePath = None Text
                        , terminationMessagePolicy = Some
                            "FallbackToLogsOnError"
                        , tty = None Bool
                        , volumeDevices =
                            None (List { devicePath : Text, name : Text })
                        , volumeMounts = Some
                          [ { mountPath = "/lsif-storage"
                            , mountPropagation = None Text
                            , name = "bundle-manager"
                            , readOnly = None Bool
                            , subPath = None Text
                            , subPathExpr = None Text
                            }
                          ]
                        , workingDir = None Text
                        }
                      ]
                    , dnsConfig =
                        None
                          { nameservers : Optional (List Text)
                          , options :
                              Optional
                                ( List
                                    { name : Optional Text
                                    , value : Optional Text
                                    }
                                )
                          , searches : Optional (List Text)
                          }
                    , dnsPolicy = None Text
                    , enableServiceLinks = None Bool
                    , ephemeralContainers =
                        None
                          ( List
                              { args : Optional (List Text)
                              , command : Optional (List Text)
                              , env :
                                  Optional
                                    ( List
                                        { name : Text
                                        , value : Optional Text
                                        , valueFrom :
                                            Optional
                                              { configMapKeyRef :
                                                  Optional
                                                    { key : Text
                                                    , name : Optional Text
                                                    , optional : Optional Bool
                                                    }
                                              , fieldRef :
                                                  Optional
                                                    { apiVersion : Optional Text
                                                    , fieldPath : Text
                                                    }
                                              , resourceFieldRef :
                                                  Optional
                                                    { containerName :
                                                        Optional Text
                                                    , divisor : Optional Text
                                                    , resource : Text
                                                    }
                                              , secretKeyRef :
                                                  Optional
                                                    { key : Text
                                                    , name : Optional Text
                                                    , optional : Optional Bool
                                                    }
                                              }
                                        }
                                    )
                              , envFrom :
                                  Optional
                                    ( List
                                        { configMapRef :
                                            Optional
                                              { name : Optional Text
                                              , optional : Optional Bool
                                              }
                                        , prefix : Optional Text
                                        , secretRef :
                                            Optional
                                              { name : Optional Text
                                              , optional : Optional Bool
                                              }
                                        }
                                    )
                              , image : Optional Text
                              , imagePullPolicy : Optional Text
                              , lifecycle :
                                  Optional
                                    { postStart :
                                        Optional
                                          { exec :
                                              Optional
                                                { command : Optional (List Text)
                                                }
                                          , httpGet :
                                              Optional
                                                { host : Optional Text
                                                , httpHeaders :
                                                    Optional
                                                      ( List
                                                          { name : Text
                                                          , value : Text
                                                          }
                                                      )
                                                , path : Optional Text
                                                , port :
                                                    < Int : Natural
                                                    | String : Text
                                                    >
                                                , scheme : Optional Text
                                                }
                                          , tcpSocket :
                                              Optional
                                                { host : Optional Text
                                                , port :
                                                    < Int : Natural
                                                    | String : Text
                                                    >
                                                }
                                          }
                                    , preStop :
                                        Optional
                                          { exec :
                                              Optional
                                                { command : Optional (List Text)
                                                }
                                          , httpGet :
                                              Optional
                                                { host : Optional Text
                                                , httpHeaders :
                                                    Optional
                                                      ( List
                                                          { name : Text
                                                          , value : Text
                                                          }
                                                      )
                                                , path : Optional Text
                                                , port :
                                                    < Int : Natural
                                                    | String : Text
                                                    >
                                                , scheme : Optional Text
                                                }
                                          , tcpSocket :
                                              Optional
                                                { host : Optional Text
                                                , port :
                                                    < Int : Natural
                                                    | String : Text
                                                    >
                                                }
                                          }
                                    }
                              , livenessProbe :
                                  Optional
                                    { exec :
                                        Optional
                                          { command : Optional (List Text) }
                                    , failureThreshold : Optional Natural
                                    , httpGet :
                                        Optional
                                          { host : Optional Text
                                          , httpHeaders :
                                              Optional
                                                ( List
                                                    { name : Text
                                                    , value : Text
                                                    }
                                                )
                                          , path : Optional Text
                                          , port :
                                              < Int : Natural | String : Text >
                                          , scheme : Optional Text
                                          }
                                    , initialDelaySeconds : Optional Natural
                                    , periodSeconds : Optional Natural
                                    , successThreshold : Optional Natural
                                    , tcpSocket :
                                        Optional
                                          { host : Optional Text
                                          , port :
                                              < Int : Natural | String : Text >
                                          }
                                    , timeoutSeconds : Optional Natural
                                    }
                              , name : Text
                              , ports :
                                  Optional
                                    ( List
                                        { containerPort : Natural
                                        , hostIP : Optional Text
                                        , hostPort : Optional Natural
                                        , name : Optional Text
                                        , protocol : Optional Text
                                        }
                                    )
                              , readinessProbe :
                                  Optional
                                    { exec :
                                        Optional
                                          { command : Optional (List Text) }
                                    , failureThreshold : Optional Natural
                                    , httpGet :
                                        Optional
                                          { host : Optional Text
                                          , httpHeaders :
                                              Optional
                                                ( List
                                                    { name : Text
                                                    , value : Text
                                                    }
                                                )
                                          , path : Optional Text
                                          , port :
                                              < Int : Natural | String : Text >
                                          , scheme : Optional Text
                                          }
                                    , initialDelaySeconds : Optional Natural
                                    , periodSeconds : Optional Natural
                                    , successThreshold : Optional Natural
                                    , tcpSocket :
                                        Optional
                                          { host : Optional Text
                                          , port :
                                              < Int : Natural | String : Text >
                                          }
                                    , timeoutSeconds : Optional Natural
                                    }
                              , resources :
                                  Optional
                                    { limits :
                                        Optional
                                          ( List
                                              { mapKey : Text, mapValue : Text }
                                          )
                                    , requests :
                                        Optional
                                          ( List
                                              { mapKey : Text, mapValue : Text }
                                          )
                                    }
                              , securityContext :
                                  Optional
                                    { allowPrivilegeEscalation : Optional Bool
                                    , capabilities :
                                        Optional
                                          { add : Optional (List Text)
                                          , drop : Optional (List Text)
                                          }
                                    , privileged : Optional Bool
                                    , procMount : Optional Text
                                    , readOnlyRootFilesystem : Optional Bool
                                    , runAsGroup : Optional Natural
                                    , runAsNonRoot : Optional Bool
                                    , runAsUser : Optional Natural
                                    , seLinuxOptions :
                                        Optional
                                          { level : Optional Text
                                          , role : Optional Text
                                          , type : Optional Text
                                          , user : Optional Text
                                          }
                                    , windowsOptions :
                                        Optional
                                          { gmsaCredentialSpec : Optional Text
                                          , gmsaCredentialSpecName :
                                              Optional Text
                                          , runAsUserName : Optional Text
                                          }
                                    }
                              , startupProbe :
                                  Optional
                                    { exec :
                                        Optional
                                          { command : Optional (List Text) }
                                    , failureThreshold : Optional Natural
                                    , httpGet :
                                        Optional
                                          { host : Optional Text
                                          , httpHeaders :
                                              Optional
                                                ( List
                                                    { name : Text
                                                    , value : Text
                                                    }
                                                )
                                          , path : Optional Text
                                          , port :
                                              < Int : Natural | String : Text >
                                          , scheme : Optional Text
                                          }
                                    , initialDelaySeconds : Optional Natural
                                    , periodSeconds : Optional Natural
                                    , successThreshold : Optional Natural
                                    , tcpSocket :
                                        Optional
                                          { host : Optional Text
                                          , port :
                                              < Int : Natural | String : Text >
                                          }
                                    , timeoutSeconds : Optional Natural
                                    }
                              , stdin : Optional Bool
                              , stdinOnce : Optional Bool
                              , targetContainerName : Optional Text
                              , terminationMessagePath : Optional Text
                              , terminationMessagePolicy : Optional Text
                              , tty : Optional Bool
                              , volumeDevices :
                                  Optional
                                    (List { devicePath : Text, name : Text })
                              , volumeMounts :
                                  Optional
                                    ( List
                                        { mountPath : Text
                                        , mountPropagation : Optional Text
                                        , name : Text
                                        , readOnly : Optional Bool
                                        , subPath : Optional Text
                                        , subPathExpr : Optional Text
                                        }
                                    )
                              , workingDir : Optional Text
                              }
                          )
                    , hostAliases =
                        None
                          ( List
                              { hostnames : Optional (List Text)
                              , ip : Optional Text
                              }
                          )
                    , hostIPC = None Bool
                    , hostNetwork = None Bool
                    , hostPID = None Bool
                    , hostname = None Text
                    , imagePullSecrets = None (List { name : Optional Text })
                    , initContainers =
                        None
                          ( List
                              { args : Optional (List Text)
                              , command : Optional (List Text)
                              , env :
                                  Optional
                                    ( List
                                        { name : Text
                                        , value : Optional Text
                                        , valueFrom :
                                            Optional
                                              { configMapKeyRef :
                                                  Optional
                                                    { key : Text
                                                    , name : Optional Text
                                                    , optional : Optional Bool
                                                    }
                                              , fieldRef :
                                                  Optional
                                                    { apiVersion : Optional Text
                                                    , fieldPath : Text
                                                    }
                                              , resourceFieldRef :
                                                  Optional
                                                    { containerName :
                                                        Optional Text
                                                    , divisor : Optional Text
                                                    , resource : Text
                                                    }
                                              , secretKeyRef :
                                                  Optional
                                                    { key : Text
                                                    , name : Optional Text
                                                    , optional : Optional Bool
                                                    }
                                              }
                                        }
                                    )
                              , envFrom :
                                  Optional
                                    ( List
                                        { configMapRef :
                                            Optional
                                              { name : Optional Text
                                              , optional : Optional Bool
                                              }
                                        , prefix : Optional Text
                                        , secretRef :
                                            Optional
                                              { name : Optional Text
                                              , optional : Optional Bool
                                              }
                                        }
                                    )
                              , image : Optional Text
                              , imagePullPolicy : Optional Text
                              , lifecycle :
                                  Optional
                                    { postStart :
                                        Optional
                                          { exec :
                                              Optional
                                                { command : Optional (List Text)
                                                }
                                          , httpGet :
                                              Optional
                                                { host : Optional Text
                                                , httpHeaders :
                                                    Optional
                                                      ( List
                                                          { name : Text
                                                          , value : Text
                                                          }
                                                      )
                                                , path : Optional Text
                                                , port :
                                                    < Int : Natural
                                                    | String : Text
                                                    >
                                                , scheme : Optional Text
                                                }
                                          , tcpSocket :
                                              Optional
                                                { host : Optional Text
                                                , port :
                                                    < Int : Natural
                                                    | String : Text
                                                    >
                                                }
                                          }
                                    , preStop :
                                        Optional
                                          { exec :
                                              Optional
                                                { command : Optional (List Text)
                                                }
                                          , httpGet :
                                              Optional
                                                { host : Optional Text
                                                , httpHeaders :
                                                    Optional
                                                      ( List
                                                          { name : Text
                                                          , value : Text
                                                          }
                                                      )
                                                , path : Optional Text
                                                , port :
                                                    < Int : Natural
                                                    | String : Text
                                                    >
                                                , scheme : Optional Text
                                                }
                                          , tcpSocket :
                                              Optional
                                                { host : Optional Text
                                                , port :
                                                    < Int : Natural
                                                    | String : Text
                                                    >
                                                }
                                          }
                                    }
                              , livenessProbe :
                                  Optional
                                    { exec :
                                        Optional
                                          { command : Optional (List Text) }
                                    , failureThreshold : Optional Natural
                                    , httpGet :
                                        Optional
                                          { host : Optional Text
                                          , httpHeaders :
                                              Optional
                                                ( List
                                                    { name : Text
                                                    , value : Text
                                                    }
                                                )
                                          , path : Optional Text
                                          , port :
                                              < Int : Natural | String : Text >
                                          , scheme : Optional Text
                                          }
                                    , initialDelaySeconds : Optional Natural
                                    , periodSeconds : Optional Natural
                                    , successThreshold : Optional Natural
                                    , tcpSocket :
                                        Optional
                                          { host : Optional Text
                                          , port :
                                              < Int : Natural | String : Text >
                                          }
                                    , timeoutSeconds : Optional Natural
                                    }
                              , name : Text
                              , ports :
                                  Optional
                                    ( List
                                        { containerPort : Natural
                                        , hostIP : Optional Text
                                        , hostPort : Optional Natural
                                        , name : Optional Text
                                        , protocol : Optional Text
                                        }
                                    )
                              , readinessProbe :
                                  Optional
                                    { exec :
                                        Optional
                                          { command : Optional (List Text) }
                                    , failureThreshold : Optional Natural
                                    , httpGet :
                                        Optional
                                          { host : Optional Text
                                          , httpHeaders :
                                              Optional
                                                ( List
                                                    { name : Text
                                                    , value : Text
                                                    }
                                                )
                                          , path : Optional Text
                                          , port :
                                              < Int : Natural | String : Text >
                                          , scheme : Optional Text
                                          }
                                    , initialDelaySeconds : Optional Natural
                                    , periodSeconds : Optional Natural
                                    , successThreshold : Optional Natural
                                    , tcpSocket :
                                        Optional
                                          { host : Optional Text
                                          , port :
                                              < Int : Natural | String : Text >
                                          }
                                    , timeoutSeconds : Optional Natural
                                    }
                              , resources :
                                  Optional
                                    { limits :
                                        Optional
                                          ( List
                                              { mapKey : Text, mapValue : Text }
                                          )
                                    , requests :
                                        Optional
                                          ( List
                                              { mapKey : Text, mapValue : Text }
                                          )
                                    }
                              , securityContext :
                                  Optional
                                    { allowPrivilegeEscalation : Optional Bool
                                    , capabilities :
                                        Optional
                                          { add : Optional (List Text)
                                          , drop : Optional (List Text)
                                          }
                                    , privileged : Optional Bool
                                    , procMount : Optional Text
                                    , readOnlyRootFilesystem : Optional Bool
                                    , runAsGroup : Optional Natural
                                    , runAsNonRoot : Optional Bool
                                    , runAsUser : Optional Natural
                                    , seLinuxOptions :
                                        Optional
                                          { level : Optional Text
                                          , role : Optional Text
                                          , type : Optional Text
                                          , user : Optional Text
                                          }
                                    , windowsOptions :
                                        Optional
                                          { gmsaCredentialSpec : Optional Text
                                          , gmsaCredentialSpecName :
                                              Optional Text
                                          , runAsUserName : Optional Text
                                          }
                                    }
                              , startupProbe :
                                  Optional
                                    { exec :
                                        Optional
                                          { command : Optional (List Text) }
                                    , failureThreshold : Optional Natural
                                    , httpGet :
                                        Optional
                                          { host : Optional Text
                                          , httpHeaders :
                                              Optional
                                                ( List
                                                    { name : Text
                                                    , value : Text
                                                    }
                                                )
                                          , path : Optional Text
                                          , port :
                                              < Int : Natural | String : Text >
                                          , scheme : Optional Text
                                          }
                                    , initialDelaySeconds : Optional Natural
                                    , periodSeconds : Optional Natural
                                    , successThreshold : Optional Natural
                                    , tcpSocket :
                                        Optional
                                          { host : Optional Text
                                          , port :
                                              < Int : Natural | String : Text >
                                          }
                                    , timeoutSeconds : Optional Natural
                                    }
                              , stdin : Optional Bool
                              , stdinOnce : Optional Bool
                              , terminationMessagePath : Optional Text
                              , terminationMessagePolicy : Optional Text
                              , tty : Optional Bool
                              , volumeDevices :
                                  Optional
                                    (List { devicePath : Text, name : Text })
                              , volumeMounts :
                                  Optional
                                    ( List
                                        { mountPath : Text
                                        , mountPropagation : Optional Text
                                        , name : Text
                                        , readOnly : Optional Bool
                                        , subPath : Optional Text
                                        , subPathExpr : Optional Text
                                        }
                                    )
                              , workingDir : Optional Text
                              }
                          )
                    , nodeName = None Text
                    , nodeSelector =
                        None (List { mapKey : Text, mapValue : Text })
                    , overhead = None (List { mapKey : Text, mapValue : Text })
                    , preemptionPolicy = None Text
                    , priority = None Natural
                    , priorityClassName = None Text
                    , readinessGates = None (List { conditionType : Text })
                    , restartPolicy = None Text
                    , runtimeClassName = None Text
                    , schedulerName = None Text
                    , securityContext = Some
                      { fsGroup = None Natural
                      , runAsGroup = None Natural
                      , runAsNonRoot = None Bool
                      , runAsUser = Some 0
                      , seLinuxOptions =
                          None
                            { level : Optional Text
                            , role : Optional Text
                            , type : Optional Text
                            , user : Optional Text
                            }
                      , supplementalGroups = None (List Natural)
                      , sysctls = None (List { name : Text, value : Text })
                      , windowsOptions =
                          None
                            { gmsaCredentialSpec : Optional Text
                            , gmsaCredentialSpecName : Optional Text
                            , runAsUserName : Optional Text
                            }
                      }
                    , serviceAccount = None Text
                    , serviceAccountName = None Text
                    , shareProcessNamespace = None Bool
                    , subdomain = None Text
                    , terminationGracePeriodSeconds = None Natural
                    , tolerations =
                        None
                          ( List
                              { effect : Optional Text
                              , key : Optional Text
                              , operator : Optional Text
                              , tolerationSeconds : Optional Natural
                              , value : Optional Text
                              }
                          )
                    , topologySpreadConstraints =
                        None
                          ( List
                              { labelSelector :
                                  Optional
                                    { matchExpressions :
                                        Optional
                                          ( List
                                              { key : Text
                                              , operator : Text
                                              , values : Optional (List Text)
                                              }
                                          )
                                    , matchLabels :
                                        Optional
                                          ( List
                                              { mapKey : Text, mapValue : Text }
                                          )
                                    }
                              , maxSkew : Natural
                              , topologyKey : Text
                              , whenUnsatisfiable : Text
                              }
                          )
                    , volumes = Some
                      [ { awsElasticBlockStore =
                            None
                              { fsType : Optional Text
                              , partition : Optional Natural
                              , readOnly : Optional Bool
                              , volumeID : Text
                              }
                        , azureDisk =
                            None
                              { cachingMode : Optional Text
                              , diskName : Text
                              , diskURI : Text
                              , fsType : Optional Text
                              , kind : Text
                              , readOnly : Optional Bool
                              }
                        , azureFile =
                            None
                              { readOnly : Optional Bool
                              , secretName : Text
                              , shareName : Text
                              }
                        , cephfs =
                            None
                              { monitors : List Text
                              , path : Optional Text
                              , readOnly : Optional Bool
                              , secretFile : Optional Text
                              , secretRef : Optional { name : Optional Text }
                              , user : Optional Text
                              }
                        , cinder =
                            None
                              { fsType : Optional Text
                              , readOnly : Optional Bool
                              , secretRef : Optional { name : Optional Text }
                              , volumeID : Text
                              }
                        , configMap =
                            None
                              { defaultMode : Optional Natural
                              , items :
                                  Optional
                                    ( List
                                        { key : Text
                                        , mode : Optional Natural
                                        , path : Text
                                        }
                                    )
                              , name : Optional Text
                              , optional : Optional Bool
                              }
                        , csi =
                            None
                              { driver : Text
                              , fsType : Optional Text
                              , nodePublishSecretRef :
                                  Optional { name : Optional Text }
                              , readOnly : Optional Bool
                              , volumeAttributes :
                                  Optional
                                    (List { mapKey : Text, mapValue : Text })
                              }
                        , downwardAPI =
                            None
                              { defaultMode : Optional Natural
                              , items :
                                  Optional
                                    ( List
                                        { fieldRef :
                                            Optional
                                              { apiVersion : Optional Text
                                              , fieldPath : Text
                                              }
                                        , mode : Optional Natural
                                        , path : Text
                                        , resourceFieldRef :
                                            Optional
                                              { containerName : Optional Text
                                              , divisor : Optional Text
                                              , resource : Text
                                              }
                                        }
                                    )
                              }
                        , emptyDir =
                            None
                              { medium : Optional Text
                              , sizeLimit : Optional Text
                              }
                        , fc =
                            None
                              { fsType : Optional Text
                              , lun : Optional Natural
                              , readOnly : Optional Bool
                              , targetWWNs : Optional (List Text)
                              , wwids : Optional (List Text)
                              }
                        , flexVolume =
                            None
                              { driver : Text
                              , fsType : Optional Text
                              , options :
                                  Optional
                                    (List { mapKey : Text, mapValue : Text })
                              , readOnly : Optional Bool
                              , secretRef : Optional { name : Optional Text }
                              }
                        , flocker =
                            None
                              { datasetName : Optional Text
                              , datasetUUID : Optional Text
                              }
                        , gcePersistentDisk =
                            None
                              { fsType : Optional Text
                              , partition : Optional Natural
                              , pdName : Text
                              , readOnly : Optional Bool
                              }
                        , gitRepo =
                            None
                              { directory : Optional Text
                              , repository : Text
                              , revision : Optional Text
                              }
                        , glusterfs =
                            None
                              { endpoints : Text
                              , path : Text
                              , readOnly : Optional Bool
                              }
                        , hostPath = None { path : Text, type : Optional Text }
                        , iscsi =
                            None
                              { chapAuthDiscovery : Optional Bool
                              , chapAuthSession : Optional Bool
                              , fsType : Optional Text
                              , initiatorName : Optional Text
                              , iqn : Text
                              , iscsiInterface : Optional Text
                              , lun : Natural
                              , portals : Optional (List Text)
                              , readOnly : Optional Bool
                              , secretRef : Optional { name : Optional Text }
                              , targetPortal : Text
                              }
                        , name = "bundle-manager"
                        , nfs =
                            None
                              { path : Text
                              , readOnly : Optional Bool
                              , server : Text
                              }
                        , persistentVolumeClaim = Some
                          { claimName = "bundle-manager", readOnly = None Bool }
                        , photonPersistentDisk =
                            None { fsType : Optional Text, pdID : Text }
                        , portworxVolume =
                            None
                              { fsType : Optional Text
                              , readOnly : Optional Bool
                              , volumeID : Text
                              }
                        , projected =
                            None
                              { defaultMode : Optional Natural
                              , sources :
                                  List
                                    { configMap :
                                        Optional
                                          { items :
                                              Optional
                                                ( List
                                                    { key : Text
                                                    , mode : Optional Natural
                                                    , path : Text
                                                    }
                                                )
                                          , name : Optional Text
                                          , optional : Optional Bool
                                          }
                                    , downwardAPI :
                                        Optional
                                          { items :
                                              Optional
                                                ( List
                                                    { fieldRef :
                                                        Optional
                                                          { apiVersion :
                                                              Optional Text
                                                          , fieldPath : Text
                                                          }
                                                    , mode : Optional Natural
                                                    , path : Text
                                                    , resourceFieldRef :
                                                        Optional
                                                          { containerName :
                                                              Optional Text
                                                          , divisor :
                                                              Optional Text
                                                          , resource : Text
                                                          }
                                                    }
                                                )
                                          }
                                    , secret :
                                        Optional
                                          { items :
                                              Optional
                                                ( List
                                                    { key : Text
                                                    , mode : Optional Natural
                                                    , path : Text
                                                    }
                                                )
                                          , name : Optional Text
                                          , optional : Optional Bool
                                          }
                                    , serviceAccountToken :
                                        Optional
                                          { audience : Optional Text
                                          , expirationSeconds : Optional Natural
                                          , path : Text
                                          }
                                    }
                              }
                        , quobyte =
                            None
                              { group : Optional Text
                              , readOnly : Optional Bool
                              , registry : Text
                              , tenant : Optional Text
                              , user : Optional Text
                              , volume : Text
                              }
                        , rbd =
                            None
                              { fsType : Optional Text
                              , image : Text
                              , keyring : Optional Text
                              , monitors : List Text
                              , pool : Optional Text
                              , readOnly : Optional Bool
                              , secretRef : Optional { name : Optional Text }
                              , user : Optional Text
                              }
                        , scaleIO =
                            None
                              { fsType : Optional Text
                              , gateway : Text
                              , protectionDomain : Optional Text
                              , readOnly : Optional Bool
                              , secretRef : { name : Optional Text }
                              , sslEnabled : Optional Bool
                              , storageMode : Optional Text
                              , storagePool : Optional Text
                              , system : Text
                              , volumeName : Optional Text
                              }
                        , secret =
                            None
                              { defaultMode : Optional Natural
                              , items :
                                  Optional
                                    ( List
                                        { key : Text
                                        , mode : Optional Natural
                                        , path : Text
                                        }
                                    )
                              , optional : Optional Bool
                              , secretName : Optional Text
                              }
                        , storageos =
                            None
                              { fsType : Optional Text
                              , readOnly : Optional Bool
                              , secretRef : Optional { name : Optional Text }
                              , volumeName : Optional Text
                              , volumeNamespace : Optional Text
                              }
                        , vsphereVolume =
                            None
                              { fsType : Optional Text
                              , storagePolicyID : Optional Text
                              , storagePolicyName : Optional Text
                              , volumePath : Text
                              }
                        }
                      ]
                    }
                  }
                }
              , status =
                  None
                    { availableReplicas : Optional Natural
                    , collisionCount : Optional Natural
                    , conditions :
                        Optional
                          ( List
                              { lastTransitionTime : Optional Text
                              , lastUpdateTime : Optional Text
                              , message : Optional Text
                              , reason : Optional Text
                              , status : Text
                              , type : Text
                              }
                          )
                    , observedGeneration : Optional Natural
                    , readyReplicas : Optional Natural
                    , replicas : Optional Natural
                    , unavailableReplicas : Optional Natural
                    , updatedReplicas : Optional Natural
                    }
              }

        in  deployment

let Worker/Service/generate =
      λ(c : Configuration/global.Type) →
        let service =
              Kubernetes/Service::{
              , apiVersion = "v1"
              , kind = "Service"
              , metadata =
                { annotations = Some
                    ( toMap
                        { `sourcegraph.prometheus/scrape` = "true"
                        , `prometheus.io/port` = "6060"
                        }
                    )
                , clusterName = None Text
                , creationTimestamp = None Text
                , deletionGracePeriodSeconds = None Natural
                , deletionTimestamp = None Text
                , finalizers = None (List Text)
                , generateName = None Text
                , generation = None Natural
                , labels = Some
                    ( toMap
                        { sourcegraph-resource-requires = "no-cluster-admin"
                        , app = "precise-code-intel-worker"
                        , deploy = "sourcegraph"
                        }
                    )
                , managedFields =
                    None
                      ( List
                          { apiVersion : Text
                          , fieldsType : Optional Text
                          , fieldsV1 :
                              Optional (List { mapKey : Text, mapValue : Text })
                          , manager : Optional Text
                          , operation : Optional Text
                          , time : Optional Text
                          }
                      )
                , name = Some "precise-code-intel-worker"
                , namespace = None Text
                , ownerReferences =
                    None
                      ( List
                          { apiVersion : Text
                          , blockOwnerDeletion : Optional Bool
                          , controller : Optional Bool
                          , kind : Text
                          , name : Text
                          , uid : Text
                          }
                      )
                , resourceVersion = None Text
                , selfLink = None Text
                , uid = None Text
                }
              , spec = Some
                { clusterIP = None Text
                , externalIPs = None (List Text)
                , externalName = None Text
                , externalTrafficPolicy = None Text
                , healthCheckNodePort = None Natural
                , ipFamily = None Text
                , loadBalancerIP = None Text
                , loadBalancerSourceRanges = None (List Text)
                , ports = Some
                  [ { name = Some "http"
                    , nodePort = None Natural
                    , port = 3188
                    , protocol = None Text
                    , targetPort = Some
                        (< Int : Natural | String : Text >.String "http")
                    }
                  , { name = Some "debug"
                    , nodePort = None Natural
                    , port = 6060
                    , protocol = None Text
                    , targetPort = Some
                        (< Int : Natural | String : Text >.String "debug")
                    }
                  ]
                , publishNotReadyAddresses = None Bool
                , selector = Some (toMap { app = "precise-code-intel-worker" })
                , sessionAffinity = None Text
                , sessionAffinityConfig =
                    None
                      { clientIP :
                          Optional { timeoutSeconds : Optional Natural }
                      }
                , topologyKeys = None (List Text)
                , type = Some "ClusterIP"
                }
              , status =
                  None
                    { loadBalancer :
                        Optional
                          { ingress :
                              Optional
                                ( List
                                    { hostname : Optional Text
                                    , ip : Optional Text
                                    }
                                )
                          }
                    }
              }

        in  service

let Worker/Deployment/generate =
      λ(c : Configuration/global.Type) →
        let deployment =
              Kubernetes/Deployment::{
              , apiVersion = "apps/v1"
              , kind = "Deployment"
              , metadata =
                { annotations = Some
                    ( toMap
                        { description =
                            "Handles conversion of uploaded precise code intelligence bundles."
                        }
                    )
                , clusterName = None Text
                , creationTimestamp = None Text
                , deletionGracePeriodSeconds = None Natural
                , deletionTimestamp = None Text
                , finalizers = None (List Text)
                , generateName = None Text
                , generation = None Natural
                , labels = Some
                    ( toMap
                        { sourcegraph-resource-requires = "no-cluster-admin"
                        , deploy = "sourcegraph"
                        }
                    )
                , managedFields =
                    None
                      ( List
                          { apiVersion : Text
                          , fieldsType : Optional Text
                          , fieldsV1 :
                              Optional (List { mapKey : Text, mapValue : Text })
                          , manager : Optional Text
                          , operation : Optional Text
                          , time : Optional Text
                          }
                      )
                , name = Some "precise-code-intel-worker"
                , namespace = None Text
                , ownerReferences =
                    None
                      ( List
                          { apiVersion : Text
                          , blockOwnerDeletion : Optional Bool
                          , controller : Optional Bool
                          , kind : Text
                          , name : Text
                          , uid : Text
                          }
                      )
                , resourceVersion = None Text
                , selfLink = None Text
                , uid = None Text
                }
              , spec = Some
                { minReadySeconds = Some 10
                , paused = None Bool
                , progressDeadlineSeconds = None Natural
                , replicas = Some 1
                , revisionHistoryLimit = Some 10
                , selector =
                  { matchExpressions =
                      None
                        ( List
                            { key : Text
                            , operator : Text
                            , values : Optional (List Text)
                            }
                        )
                  , matchLabels = Some
                      (toMap { app = "precise-code-intel-worker" })
                  }
                , strategy = Some
                  { rollingUpdate = Some
                    { maxSurge = Some (< Int : Natural | String : Text >.Int 1)
                    , maxUnavailable = Some
                        (< Int : Natural | String : Text >.Int 1)
                    }
                  , type = Some "RollingUpdate"
                  }
                , template =
                  { metadata =
                    { annotations =
                        None (List { mapKey : Text, mapValue : Text })
                    , clusterName = None Text
                    , creationTimestamp = None Text
                    , deletionGracePeriodSeconds = None Natural
                    , deletionTimestamp = None Text
                    , finalizers = None (List Text)
                    , generateName = None Text
                    , generation = None Natural
                    , labels = Some
                        ( toMap
                            { app = "precise-code-intel-worker"
                            , deploy = "sourcegraph"
                            }
                        )
                    , managedFields =
                        None
                          ( List
                              { apiVersion : Text
                              , fieldsType : Optional Text
                              , fieldsV1 :
                                  Optional
                                    (List { mapKey : Text, mapValue : Text })
                              , manager : Optional Text
                              , operation : Optional Text
                              , time : Optional Text
                              }
                          )
                    , name = None Text
                    , namespace = None Text
                    , ownerReferences =
                        None
                          ( List
                              { apiVersion : Text
                              , blockOwnerDeletion : Optional Bool
                              , controller : Optional Bool
                              , kind : Text
                              , name : Text
                              , uid : Text
                              }
                          )
                    , resourceVersion = None Text
                    , selfLink = None Text
                    , uid = None Text
                    }
                  , spec = Some
                    { activeDeadlineSeconds = None Natural
                    , affinity =
                        None
                          { nodeAffinity :
                              Optional
                                { preferredDuringSchedulingIgnoredDuringExecution :
                                    Optional
                                      ( List
                                          { preference :
                                              { matchExpressions :
                                                  Optional
                                                    ( List
                                                        { key : Text
                                                        , operator : Text
                                                        , values :
                                                            Optional (List Text)
                                                        }
                                                    )
                                              , matchFields :
                                                  Optional
                                                    ( List
                                                        { key : Text
                                                        , operator : Text
                                                        , values :
                                                            Optional (List Text)
                                                        }
                                                    )
                                              }
                                          , weight : Natural
                                          }
                                      )
                                , requiredDuringSchedulingIgnoredDuringExecution :
                                    Optional
                                      { nodeSelectorTerms :
                                          List
                                            { matchExpressions :
                                                Optional
                                                  ( List
                                                      { key : Text
                                                      , operator : Text
                                                      , values :
                                                          Optional (List Text)
                                                      }
                                                  )
                                            , matchFields :
                                                Optional
                                                  ( List
                                                      { key : Text
                                                      , operator : Text
                                                      , values :
                                                          Optional (List Text)
                                                      }
                                                  )
                                            }
                                      }
                                }
                          , podAffinity :
                              Optional
                                { preferredDuringSchedulingIgnoredDuringExecution :
                                    Optional
                                      ( List
                                          { podAffinityTerm :
                                              { labelSelector :
                                                  Optional
                                                    { matchExpressions :
                                                        Optional
                                                          ( List
                                                              { key : Text
                                                              , operator : Text
                                                              , values :
                                                                  Optional
                                                                    (List Text)
                                                              }
                                                          )
                                                    , matchLabels :
                                                        Optional
                                                          ( List
                                                              { mapKey : Text
                                                              , mapValue : Text
                                                              }
                                                          )
                                                    }
                                              , namespaces :
                                                  Optional (List Text)
                                              , topologyKey : Text
                                              }
                                          , weight : Natural
                                          }
                                      )
                                , requiredDuringSchedulingIgnoredDuringExecution :
                                    Optional
                                      ( List
                                          { labelSelector :
                                              Optional
                                                { matchExpressions :
                                                    Optional
                                                      ( List
                                                          { key : Text
                                                          , operator : Text
                                                          , values :
                                                              Optional
                                                                (List Text)
                                                          }
                                                      )
                                                , matchLabels :
                                                    Optional
                                                      ( List
                                                          { mapKey : Text
                                                          , mapValue : Text
                                                          }
                                                      )
                                                }
                                          , namespaces : Optional (List Text)
                                          , topologyKey : Text
                                          }
                                      )
                                }
                          , podAntiAffinity :
                              Optional
                                { preferredDuringSchedulingIgnoredDuringExecution :
                                    Optional
                                      ( List
                                          { podAffinityTerm :
                                              { labelSelector :
                                                  Optional
                                                    { matchExpressions :
                                                        Optional
                                                          ( List
                                                              { key : Text
                                                              , operator : Text
                                                              , values :
                                                                  Optional
                                                                    (List Text)
                                                              }
                                                          )
                                                    , matchLabels :
                                                        Optional
                                                          ( List
                                                              { mapKey : Text
                                                              , mapValue : Text
                                                              }
                                                          )
                                                    }
                                              , namespaces :
                                                  Optional (List Text)
                                              , topologyKey : Text
                                              }
                                          , weight : Natural
                                          }
                                      )
                                , requiredDuringSchedulingIgnoredDuringExecution :
                                    Optional
                                      ( List
                                          { labelSelector :
                                              Optional
                                                { matchExpressions :
                                                    Optional
                                                      ( List
                                                          { key : Text
                                                          , operator : Text
                                                          , values :
                                                              Optional
                                                                (List Text)
                                                          }
                                                      )
                                                , matchLabels :
                                                    Optional
                                                      ( List
                                                          { mapKey : Text
                                                          , mapValue : Text
                                                          }
                                                      )
                                                }
                                          , namespaces : Optional (List Text)
                                          , topologyKey : Text
                                          }
                                      )
                                }
                          }
                    , automountServiceAccountToken = None Bool
                    , containers =
                      [ { args = None (List Text)
                        , command = None (List Text)
                        , env = Some
                          [ { name = "NUM_WORKERS"
                            , value = Some "4"
                            , valueFrom =
                                None
                                  { configMapKeyRef :
                                      Optional
                                        { key : Text
                                        , name : Optional Text
                                        , optional : Optional Bool
                                        }
                                  , fieldRef :
                                      Optional
                                        { apiVersion : Optional Text
                                        , fieldPath : Text
                                        }
                                  , resourceFieldRef :
                                      Optional
                                        { containerName : Optional Text
                                        , divisor : Optional Text
                                        , resource : Text
                                        }
                                  , secretKeyRef :
                                      Optional
                                        { key : Text
                                        , name : Optional Text
                                        , optional : Optional Bool
                                        }
                                  }
                            }
                          , { name = "PRECISE_CODE_INTEL_BUNDLE_MANAGER_URL"
                            , value = Some
                                "http://precise-code-intel-bundle-manager:3187"
                            , valueFrom =
                                None
                                  { configMapKeyRef :
                                      Optional
                                        { key : Text
                                        , name : Optional Text
                                        , optional : Optional Bool
                                        }
                                  , fieldRef :
                                      Optional
                                        { apiVersion : Optional Text
                                        , fieldPath : Text
                                        }
                                  , resourceFieldRef :
                                      Optional
                                        { containerName : Optional Text
                                        , divisor : Optional Text
                                        , resource : Text
                                        }
                                  , secretKeyRef :
                                      Optional
                                        { key : Text
                                        , name : Optional Text
                                        , optional : Optional Bool
                                        }
                                  }
                            }
                          , { name = "POD_NAME"
                            , value = None Text
                            , valueFrom = Some
                              { configMapKeyRef =
                                  None
                                    { key : Text
                                    , name : Optional Text
                                    , optional : Optional Bool
                                    }
                              , fieldRef = Some
                                { apiVersion = None Text
                                , fieldPath = "metadata.name"
                                }
                              , resourceFieldRef =
                                  None
                                    { containerName : Optional Text
                                    , divisor : Optional Text
                                    , resource : Text
                                    }
                              , secretKeyRef =
                                  None
                                    { key : Text
                                    , name : Optional Text
                                    , optional : Optional Bool
                                    }
                              }
                            }
                          ]
                        , envFrom =
                            None
                              ( List
                                  { configMapRef :
                                      Optional
                                        { name : Optional Text
                                        , optional : Optional Bool
                                        }
                                  , prefix : Optional Text
                                  , secretRef :
                                      Optional
                                        { name : Optional Text
                                        , optional : Optional Bool
                                        }
                                  }
                              )
                        , image = Some
                            "index.docker.io/sourcegraph/precise-code-intel-worker:3.16.1@sha256:07ca2bb9fbc5546273fe9e2373d0fbe3c4d4b3be6ca02324b5c98e6717785f82"
                        , imagePullPolicy = None Text
                        , lifecycle =
                            None
                              { postStart :
                                  Optional
                                    { exec :
                                        Optional
                                          { command : Optional (List Text) }
                                    , httpGet :
                                        Optional
                                          { host : Optional Text
                                          , httpHeaders :
                                              Optional
                                                ( List
                                                    { name : Text
                                                    , value : Text
                                                    }
                                                )
                                          , path : Optional Text
                                          , port :
                                              < Int : Natural | String : Text >
                                          , scheme : Optional Text
                                          }
                                    , tcpSocket :
                                        Optional
                                          { host : Optional Text
                                          , port :
                                              < Int : Natural | String : Text >
                                          }
                                    }
                              , preStop :
                                  Optional
                                    { exec :
                                        Optional
                                          { command : Optional (List Text) }
                                    , httpGet :
                                        Optional
                                          { host : Optional Text
                                          , httpHeaders :
                                              Optional
                                                ( List
                                                    { name : Text
                                                    , value : Text
                                                    }
                                                )
                                          , path : Optional Text
                                          , port :
                                              < Int : Natural | String : Text >
                                          , scheme : Optional Text
                                          }
                                    , tcpSocket :
                                        Optional
                                          { host : Optional Text
                                          , port :
                                              < Int : Natural | String : Text >
                                          }
                                    }
                              }
                        , livenessProbe = Some
                          { exec = None { command : Optional (List Text) }
                          , failureThreshold = None Natural
                          , httpGet = Some
                            { host = None Text
                            , httpHeaders =
                                None (List { name : Text, value : Text })
                            , path = Some "/healthz"
                            , port =
                                < Int : Natural | String : Text >.String "http"
                            , scheme = Some "HTTP"
                            }
                          , initialDelaySeconds = Some 60
                          , periodSeconds = None Natural
                          , successThreshold = None Natural
                          , tcpSocket =
                              None
                                { host : Optional Text
                                , port : < Int : Natural | String : Text >
                                }
                          , timeoutSeconds = Some 5
                          }
                        , name = "precise-code-intel-worker"
                        , ports = Some
                          [ { containerPort = 3188
                            , hostIP = None Text
                            , hostPort = None Natural
                            , name = Some "http"
                            , protocol = None Text
                            }
                          , { containerPort = 6060
                            , hostIP = None Text
                            , hostPort = None Natural
                            , name = Some "debug"
                            , protocol = None Text
                            }
                          ]
                        , readinessProbe = Some
                          { exec = None { command : Optional (List Text) }
                          , failureThreshold = None Natural
                          , httpGet = Some
                            { host = None Text
                            , httpHeaders =
                                None (List { name : Text, value : Text })
                            , path = Some "/healthz"
                            , port =
                                < Int : Natural | String : Text >.String "http"
                            , scheme = Some "HTTP"
                            }
                          , initialDelaySeconds = None Natural
                          , periodSeconds = Some 5
                          , successThreshold = None Natural
                          , tcpSocket =
                              None
                                { host : Optional Text
                                , port : < Int : Natural | String : Text >
                                }
                          , timeoutSeconds = Some 5
                          }
                        , resources = Some
                          { limits = Some (toMap { memory = "4G", cpu = "2" })
                          , requests = Some
                              (toMap { memory = "2G", cpu = "500m" })
                          }
                        , securityContext =
                            None
                              { allowPrivilegeEscalation : Optional Bool
                              , capabilities :
                                  Optional
                                    { add : Optional (List Text)
                                    , drop : Optional (List Text)
                                    }
                              , privileged : Optional Bool
                              , procMount : Optional Text
                              , readOnlyRootFilesystem : Optional Bool
                              , runAsGroup : Optional Natural
                              , runAsNonRoot : Optional Bool
                              , runAsUser : Optional Natural
                              , seLinuxOptions :
                                  Optional
                                    { level : Optional Text
                                    , role : Optional Text
                                    , type : Optional Text
                                    , user : Optional Text
                                    }
                              , windowsOptions :
                                  Optional
                                    { gmsaCredentialSpec : Optional Text
                                    , gmsaCredentialSpecName : Optional Text
                                    , runAsUserName : Optional Text
                                    }
                              }
                        , startupProbe =
                            None
                              { exec :
                                  Optional { command : Optional (List Text) }
                              , failureThreshold : Optional Natural
                              , httpGet :
                                  Optional
                                    { host : Optional Text
                                    , httpHeaders :
                                        Optional
                                          (List { name : Text, value : Text })
                                    , path : Optional Text
                                    , port : < Int : Natural | String : Text >
                                    , scheme : Optional Text
                                    }
                              , initialDelaySeconds : Optional Natural
                              , periodSeconds : Optional Natural
                              , successThreshold : Optional Natural
                              , tcpSocket :
                                  Optional
                                    { host : Optional Text
                                    , port : < Int : Natural | String : Text >
                                    }
                              , timeoutSeconds : Optional Natural
                              }
                        , stdin = None Bool
                        , stdinOnce = None Bool
                        , terminationMessagePath = None Text
                        , terminationMessagePolicy = Some
                            "FallbackToLogsOnError"
                        , tty = None Bool
                        , volumeDevices =
                            None (List { devicePath : Text, name : Text })
                        , volumeMounts =
                            None
                              ( List
                                  { mountPath : Text
                                  , mountPropagation : Optional Text
                                  , name : Text
                                  , readOnly : Optional Bool
                                  , subPath : Optional Text
                                  , subPathExpr : Optional Text
                                  }
                              )
                        , workingDir = None Text
                        }
                      ]
                    , dnsConfig =
                        None
                          { nameservers : Optional (List Text)
                          , options :
                              Optional
                                ( List
                                    { name : Optional Text
                                    , value : Optional Text
                                    }
                                )
                          , searches : Optional (List Text)
                          }
                    , dnsPolicy = None Text
                    , enableServiceLinks = None Bool
                    , ephemeralContainers =
                        None
                          ( List
                              { args : Optional (List Text)
                              , command : Optional (List Text)
                              , env :
                                  Optional
                                    ( List
                                        { name : Text
                                        , value : Optional Text
                                        , valueFrom :
                                            Optional
                                              { configMapKeyRef :
                                                  Optional
                                                    { key : Text
                                                    , name : Optional Text
                                                    , optional : Optional Bool
                                                    }
                                              , fieldRef :
                                                  Optional
                                                    { apiVersion : Optional Text
                                                    , fieldPath : Text
                                                    }
                                              , resourceFieldRef :
                                                  Optional
                                                    { containerName :
                                                        Optional Text
                                                    , divisor : Optional Text
                                                    , resource : Text
                                                    }
                                              , secretKeyRef :
                                                  Optional
                                                    { key : Text
                                                    , name : Optional Text
                                                    , optional : Optional Bool
                                                    }
                                              }
                                        }
                                    )
                              , envFrom :
                                  Optional
                                    ( List
                                        { configMapRef :
                                            Optional
                                              { name : Optional Text
                                              , optional : Optional Bool
                                              }
                                        , prefix : Optional Text
                                        , secretRef :
                                            Optional
                                              { name : Optional Text
                                              , optional : Optional Bool
                                              }
                                        }
                                    )
                              , image : Optional Text
                              , imagePullPolicy : Optional Text
                              , lifecycle :
                                  Optional
                                    { postStart :
                                        Optional
                                          { exec :
                                              Optional
                                                { command : Optional (List Text)
                                                }
                                          , httpGet :
                                              Optional
                                                { host : Optional Text
                                                , httpHeaders :
                                                    Optional
                                                      ( List
                                                          { name : Text
                                                          , value : Text
                                                          }
                                                      )
                                                , path : Optional Text
                                                , port :
                                                    < Int : Natural
                                                    | String : Text
                                                    >
                                                , scheme : Optional Text
                                                }
                                          , tcpSocket :
                                              Optional
                                                { host : Optional Text
                                                , port :
                                                    < Int : Natural
                                                    | String : Text
                                                    >
                                                }
                                          }
                                    , preStop :
                                        Optional
                                          { exec :
                                              Optional
                                                { command : Optional (List Text)
                                                }
                                          , httpGet :
                                              Optional
                                                { host : Optional Text
                                                , httpHeaders :
                                                    Optional
                                                      ( List
                                                          { name : Text
                                                          , value : Text
                                                          }
                                                      )
                                                , path : Optional Text
                                                , port :
                                                    < Int : Natural
                                                    | String : Text
                                                    >
                                                , scheme : Optional Text
                                                }
                                          , tcpSocket :
                                              Optional
                                                { host : Optional Text
                                                , port :
                                                    < Int : Natural
                                                    | String : Text
                                                    >
                                                }
                                          }
                                    }
                              , livenessProbe :
                                  Optional
                                    { exec :
                                        Optional
                                          { command : Optional (List Text) }
                                    , failureThreshold : Optional Natural
                                    , httpGet :
                                        Optional
                                          { host : Optional Text
                                          , httpHeaders :
                                              Optional
                                                ( List
                                                    { name : Text
                                                    , value : Text
                                                    }
                                                )
                                          , path : Optional Text
                                          , port :
                                              < Int : Natural | String : Text >
                                          , scheme : Optional Text
                                          }
                                    , initialDelaySeconds : Optional Natural
                                    , periodSeconds : Optional Natural
                                    , successThreshold : Optional Natural
                                    , tcpSocket :
                                        Optional
                                          { host : Optional Text
                                          , port :
                                              < Int : Natural | String : Text >
                                          }
                                    , timeoutSeconds : Optional Natural
                                    }
                              , name : Text
                              , ports :
                                  Optional
                                    ( List
                                        { containerPort : Natural
                                        , hostIP : Optional Text
                                        , hostPort : Optional Natural
                                        , name : Optional Text
                                        , protocol : Optional Text
                                        }
                                    )
                              , readinessProbe :
                                  Optional
                                    { exec :
                                        Optional
                                          { command : Optional (List Text) }
                                    , failureThreshold : Optional Natural
                                    , httpGet :
                                        Optional
                                          { host : Optional Text
                                          , httpHeaders :
                                              Optional
                                                ( List
                                                    { name : Text
                                                    , value : Text
                                                    }
                                                )
                                          , path : Optional Text
                                          , port :
                                              < Int : Natural | String : Text >
                                          , scheme : Optional Text
                                          }
                                    , initialDelaySeconds : Optional Natural
                                    , periodSeconds : Optional Natural
                                    , successThreshold : Optional Natural
                                    , tcpSocket :
                                        Optional
                                          { host : Optional Text
                                          , port :
                                              < Int : Natural | String : Text >
                                          }
                                    , timeoutSeconds : Optional Natural
                                    }
                              , resources :
                                  Optional
                                    { limits :
                                        Optional
                                          ( List
                                              { mapKey : Text, mapValue : Text }
                                          )
                                    , requests :
                                        Optional
                                          ( List
                                              { mapKey : Text, mapValue : Text }
                                          )
                                    }
                              , securityContext :
                                  Optional
                                    { allowPrivilegeEscalation : Optional Bool
                                    , capabilities :
                                        Optional
                                          { add : Optional (List Text)
                                          , drop : Optional (List Text)
                                          }
                                    , privileged : Optional Bool
                                    , procMount : Optional Text
                                    , readOnlyRootFilesystem : Optional Bool
                                    , runAsGroup : Optional Natural
                                    , runAsNonRoot : Optional Bool
                                    , runAsUser : Optional Natural
                                    , seLinuxOptions :
                                        Optional
                                          { level : Optional Text
                                          , role : Optional Text
                                          , type : Optional Text
                                          , user : Optional Text
                                          }
                                    , windowsOptions :
                                        Optional
                                          { gmsaCredentialSpec : Optional Text
                                          , gmsaCredentialSpecName :
                                              Optional Text
                                          , runAsUserName : Optional Text
                                          }
                                    }
                              , startupProbe :
                                  Optional
                                    { exec :
                                        Optional
                                          { command : Optional (List Text) }
                                    , failureThreshold : Optional Natural
                                    , httpGet :
                                        Optional
                                          { host : Optional Text
                                          , httpHeaders :
                                              Optional
                                                ( List
                                                    { name : Text
                                                    , value : Text
                                                    }
                                                )
                                          , path : Optional Text
                                          , port :
                                              < Int : Natural | String : Text >
                                          , scheme : Optional Text
                                          }
                                    , initialDelaySeconds : Optional Natural
                                    , periodSeconds : Optional Natural
                                    , successThreshold : Optional Natural
                                    , tcpSocket :
                                        Optional
                                          { host : Optional Text
                                          , port :
                                              < Int : Natural | String : Text >
                                          }
                                    , timeoutSeconds : Optional Natural
                                    }
                              , stdin : Optional Bool
                              , stdinOnce : Optional Bool
                              , targetContainerName : Optional Text
                              , terminationMessagePath : Optional Text
                              , terminationMessagePolicy : Optional Text
                              , tty : Optional Bool
                              , volumeDevices :
                                  Optional
                                    (List { devicePath : Text, name : Text })
                              , volumeMounts :
                                  Optional
                                    ( List
                                        { mountPath : Text
                                        , mountPropagation : Optional Text
                                        , name : Text
                                        , readOnly : Optional Bool
                                        , subPath : Optional Text
                                        , subPathExpr : Optional Text
                                        }
                                    )
                              , workingDir : Optional Text
                              }
                          )
                    , hostAliases =
                        None
                          ( List
                              { hostnames : Optional (List Text)
                              , ip : Optional Text
                              }
                          )
                    , hostIPC = None Bool
                    , hostNetwork = None Bool
                    , hostPID = None Bool
                    , hostname = None Text
                    , imagePullSecrets = None (List { name : Optional Text })
                    , initContainers =
                        None
                          ( List
                              { args : Optional (List Text)
                              , command : Optional (List Text)
                              , env :
                                  Optional
                                    ( List
                                        { name : Text
                                        , value : Optional Text
                                        , valueFrom :
                                            Optional
                                              { configMapKeyRef :
                                                  Optional
                                                    { key : Text
                                                    , name : Optional Text
                                                    , optional : Optional Bool
                                                    }
                                              , fieldRef :
                                                  Optional
                                                    { apiVersion : Optional Text
                                                    , fieldPath : Text
                                                    }
                                              , resourceFieldRef :
                                                  Optional
                                                    { containerName :
                                                        Optional Text
                                                    , divisor : Optional Text
                                                    , resource : Text
                                                    }
                                              , secretKeyRef :
                                                  Optional
                                                    { key : Text
                                                    , name : Optional Text
                                                    , optional : Optional Bool
                                                    }
                                              }
                                        }
                                    )
                              , envFrom :
                                  Optional
                                    ( List
                                        { configMapRef :
                                            Optional
                                              { name : Optional Text
                                              , optional : Optional Bool
                                              }
                                        , prefix : Optional Text
                                        , secretRef :
                                            Optional
                                              { name : Optional Text
                                              , optional : Optional Bool
                                              }
                                        }
                                    )
                              , image : Optional Text
                              , imagePullPolicy : Optional Text
                              , lifecycle :
                                  Optional
                                    { postStart :
                                        Optional
                                          { exec :
                                              Optional
                                                { command : Optional (List Text)
                                                }
                                          , httpGet :
                                              Optional
                                                { host : Optional Text
                                                , httpHeaders :
                                                    Optional
                                                      ( List
                                                          { name : Text
                                                          , value : Text
                                                          }
                                                      )
                                                , path : Optional Text
                                                , port :
                                                    < Int : Natural
                                                    | String : Text
                                                    >
                                                , scheme : Optional Text
                                                }
                                          , tcpSocket :
                                              Optional
                                                { host : Optional Text
                                                , port :
                                                    < Int : Natural
                                                    | String : Text
                                                    >
                                                }
                                          }
                                    , preStop :
                                        Optional
                                          { exec :
                                              Optional
                                                { command : Optional (List Text)
                                                }
                                          , httpGet :
                                              Optional
                                                { host : Optional Text
                                                , httpHeaders :
                                                    Optional
                                                      ( List
                                                          { name : Text
                                                          , value : Text
                                                          }
                                                      )
                                                , path : Optional Text
                                                , port :
                                                    < Int : Natural
                                                    | String : Text
                                                    >
                                                , scheme : Optional Text
                                                }
                                          , tcpSocket :
                                              Optional
                                                { host : Optional Text
                                                , port :
                                                    < Int : Natural
                                                    | String : Text
                                                    >
                                                }
                                          }
                                    }
                              , livenessProbe :
                                  Optional
                                    { exec :
                                        Optional
                                          { command : Optional (List Text) }
                                    , failureThreshold : Optional Natural
                                    , httpGet :
                                        Optional
                                          { host : Optional Text
                                          , httpHeaders :
                                              Optional
                                                ( List
                                                    { name : Text
                                                    , value : Text
                                                    }
                                                )
                                          , path : Optional Text
                                          , port :
                                              < Int : Natural | String : Text >
                                          , scheme : Optional Text
                                          }
                                    , initialDelaySeconds : Optional Natural
                                    , periodSeconds : Optional Natural
                                    , successThreshold : Optional Natural
                                    , tcpSocket :
                                        Optional
                                          { host : Optional Text
                                          , port :
                                              < Int : Natural | String : Text >
                                          }
                                    , timeoutSeconds : Optional Natural
                                    }
                              , name : Text
                              , ports :
                                  Optional
                                    ( List
                                        { containerPort : Natural
                                        , hostIP : Optional Text
                                        , hostPort : Optional Natural
                                        , name : Optional Text
                                        , protocol : Optional Text
                                        }
                                    )
                              , readinessProbe :
                                  Optional
                                    { exec :
                                        Optional
                                          { command : Optional (List Text) }
                                    , failureThreshold : Optional Natural
                                    , httpGet :
                                        Optional
                                          { host : Optional Text
                                          , httpHeaders :
                                              Optional
                                                ( List
                                                    { name : Text
                                                    , value : Text
                                                    }
                                                )
                                          , path : Optional Text
                                          , port :
                                              < Int : Natural | String : Text >
                                          , scheme : Optional Text
                                          }
                                    , initialDelaySeconds : Optional Natural
                                    , periodSeconds : Optional Natural
                                    , successThreshold : Optional Natural
                                    , tcpSocket :
                                        Optional
                                          { host : Optional Text
                                          , port :
                                              < Int : Natural | String : Text >
                                          }
                                    , timeoutSeconds : Optional Natural
                                    }
                              , resources :
                                  Optional
                                    { limits :
                                        Optional
                                          ( List
                                              { mapKey : Text, mapValue : Text }
                                          )
                                    , requests :
                                        Optional
                                          ( List
                                              { mapKey : Text, mapValue : Text }
                                          )
                                    }
                              , securityContext :
                                  Optional
                                    { allowPrivilegeEscalation : Optional Bool
                                    , capabilities :
                                        Optional
                                          { add : Optional (List Text)
                                          , drop : Optional (List Text)
                                          }
                                    , privileged : Optional Bool
                                    , procMount : Optional Text
                                    , readOnlyRootFilesystem : Optional Bool
                                    , runAsGroup : Optional Natural
                                    , runAsNonRoot : Optional Bool
                                    , runAsUser : Optional Natural
                                    , seLinuxOptions :
                                        Optional
                                          { level : Optional Text
                                          , role : Optional Text
                                          , type : Optional Text
                                          , user : Optional Text
                                          }
                                    , windowsOptions :
                                        Optional
                                          { gmsaCredentialSpec : Optional Text
                                          , gmsaCredentialSpecName :
                                              Optional Text
                                          , runAsUserName : Optional Text
                                          }
                                    }
                              , startupProbe :
                                  Optional
                                    { exec :
                                        Optional
                                          { command : Optional (List Text) }
                                    , failureThreshold : Optional Natural
                                    , httpGet :
                                        Optional
                                          { host : Optional Text
                                          , httpHeaders :
                                              Optional
                                                ( List
                                                    { name : Text
                                                    , value : Text
                                                    }
                                                )
                                          , path : Optional Text
                                          , port :
                                              < Int : Natural | String : Text >
                                          , scheme : Optional Text
                                          }
                                    , initialDelaySeconds : Optional Natural
                                    , periodSeconds : Optional Natural
                                    , successThreshold : Optional Natural
                                    , tcpSocket :
                                        Optional
                                          { host : Optional Text
                                          , port :
                                              < Int : Natural | String : Text >
                                          }
                                    , timeoutSeconds : Optional Natural
                                    }
                              , stdin : Optional Bool
                              , stdinOnce : Optional Bool
                              , terminationMessagePath : Optional Text
                              , terminationMessagePolicy : Optional Text
                              , tty : Optional Bool
                              , volumeDevices :
                                  Optional
                                    (List { devicePath : Text, name : Text })
                              , volumeMounts :
                                  Optional
                                    ( List
                                        { mountPath : Text
                                        , mountPropagation : Optional Text
                                        , name : Text
                                        , readOnly : Optional Bool
                                        , subPath : Optional Text
                                        , subPathExpr : Optional Text
                                        }
                                    )
                              , workingDir : Optional Text
                              }
                          )
                    , nodeName = None Text
                    , nodeSelector =
                        None (List { mapKey : Text, mapValue : Text })
                    , overhead = None (List { mapKey : Text, mapValue : Text })
                    , preemptionPolicy = None Text
                    , priority = None Natural
                    , priorityClassName = None Text
                    , readinessGates = None (List { conditionType : Text })
                    , restartPolicy = None Text
                    , runtimeClassName = None Text
                    , schedulerName = None Text
                    , securityContext = Some
                      { fsGroup = None Natural
                      , runAsGroup = None Natural
                      , runAsNonRoot = None Bool
                      , runAsUser = Some 0
                      , seLinuxOptions =
                          None
                            { level : Optional Text
                            , role : Optional Text
                            , type : Optional Text
                            , user : Optional Text
                            }
                      , supplementalGroups = None (List Natural)
                      , sysctls = None (List { name : Text, value : Text })
                      , windowsOptions =
                          None
                            { gmsaCredentialSpec : Optional Text
                            , gmsaCredentialSpecName : Optional Text
                            , runAsUserName : Optional Text
                            }
                      }
                    , serviceAccount = None Text
                    , serviceAccountName = None Text
                    , shareProcessNamespace = None Bool
                    , subdomain = None Text
                    , terminationGracePeriodSeconds = None Natural
                    , tolerations =
                        None
                          ( List
                              { effect : Optional Text
                              , key : Optional Text
                              , operator : Optional Text
                              , tolerationSeconds : Optional Natural
                              , value : Optional Text
                              }
                          )
                    , topologySpreadConstraints =
                        None
                          ( List
                              { labelSelector :
                                  Optional
                                    { matchExpressions :
                                        Optional
                                          ( List
                                              { key : Text
                                              , operator : Text
                                              , values : Optional (List Text)
                                              }
                                          )
                                    , matchLabels :
                                        Optional
                                          ( List
                                              { mapKey : Text, mapValue : Text }
                                          )
                                    }
                              , maxSkew : Natural
                              , topologyKey : Text
                              , whenUnsatisfiable : Text
                              }
                          )
                    , volumes =
                        None
                          ( List
                              { awsElasticBlockStore :
                                  Optional
                                    { fsType : Optional Text
                                    , partition : Optional Natural
                                    , readOnly : Optional Bool
                                    , volumeID : Text
                                    }
                              , azureDisk :
                                  Optional
                                    { cachingMode : Optional Text
                                    , diskName : Text
                                    , diskURI : Text
                                    , fsType : Optional Text
                                    , kind : Text
                                    , readOnly : Optional Bool
                                    }
                              , azureFile :
                                  Optional
                                    { readOnly : Optional Bool
                                    , secretName : Text
                                    , shareName : Text
                                    }
                              , cephfs :
                                  Optional
                                    { monitors : List Text
                                    , path : Optional Text
                                    , readOnly : Optional Bool
                                    , secretFile : Optional Text
                                    , secretRef :
                                        Optional { name : Optional Text }
                                    , user : Optional Text
                                    }
                              , cinder :
                                  Optional
                                    { fsType : Optional Text
                                    , readOnly : Optional Bool
                                    , secretRef :
                                        Optional { name : Optional Text }
                                    , volumeID : Text
                                    }
                              , configMap :
                                  Optional
                                    { defaultMode : Optional Natural
                                    , items :
                                        Optional
                                          ( List
                                              { key : Text
                                              , mode : Optional Natural
                                              , path : Text
                                              }
                                          )
                                    , name : Optional Text
                                    , optional : Optional Bool
                                    }
                              , csi :
                                  Optional
                                    { driver : Text
                                    , fsType : Optional Text
                                    , nodePublishSecretRef :
                                        Optional { name : Optional Text }
                                    , readOnly : Optional Bool
                                    , volumeAttributes :
                                        Optional
                                          ( List
                                              { mapKey : Text, mapValue : Text }
                                          )
                                    }
                              , downwardAPI :
                                  Optional
                                    { defaultMode : Optional Natural
                                    , items :
                                        Optional
                                          ( List
                                              { fieldRef :
                                                  Optional
                                                    { apiVersion : Optional Text
                                                    , fieldPath : Text
                                                    }
                                              , mode : Optional Natural
                                              , path : Text
                                              , resourceFieldRef :
                                                  Optional
                                                    { containerName :
                                                        Optional Text
                                                    , divisor : Optional Text
                                                    , resource : Text
                                                    }
                                              }
                                          )
                                    }
                              , emptyDir :
                                  Optional
                                    { medium : Optional Text
                                    , sizeLimit : Optional Text
                                    }
                              , fc :
                                  Optional
                                    { fsType : Optional Text
                                    , lun : Optional Natural
                                    , readOnly : Optional Bool
                                    , targetWWNs : Optional (List Text)
                                    , wwids : Optional (List Text)
                                    }
                              , flexVolume :
                                  Optional
                                    { driver : Text
                                    , fsType : Optional Text
                                    , options :
                                        Optional
                                          ( List
                                              { mapKey : Text, mapValue : Text }
                                          )
                                    , readOnly : Optional Bool
                                    , secretRef :
                                        Optional { name : Optional Text }
                                    }
                              , flocker :
                                  Optional
                                    { datasetName : Optional Text
                                    , datasetUUID : Optional Text
                                    }
                              , gcePersistentDisk :
                                  Optional
                                    { fsType : Optional Text
                                    , partition : Optional Natural
                                    , pdName : Text
                                    , readOnly : Optional Bool
                                    }
                              , gitRepo :
                                  Optional
                                    { directory : Optional Text
                                    , repository : Text
                                    , revision : Optional Text
                                    }
                              , glusterfs :
                                  Optional
                                    { endpoints : Text
                                    , path : Text
                                    , readOnly : Optional Bool
                                    }
                              , hostPath :
                                  Optional { path : Text, type : Optional Text }
                              , iscsi :
                                  Optional
                                    { chapAuthDiscovery : Optional Bool
                                    , chapAuthSession : Optional Bool
                                    , fsType : Optional Text
                                    , initiatorName : Optional Text
                                    , iqn : Text
                                    , iscsiInterface : Optional Text
                                    , lun : Natural
                                    , portals : Optional (List Text)
                                    , readOnly : Optional Bool
                                    , secretRef :
                                        Optional { name : Optional Text }
                                    , targetPortal : Text
                                    }
                              , name : Text
                              , nfs :
                                  Optional
                                    { path : Text
                                    , readOnly : Optional Bool
                                    , server : Text
                                    }
                              , persistentVolumeClaim :
                                  Optional
                                    { claimName : Text
                                    , readOnly : Optional Bool
                                    }
                              , photonPersistentDisk :
                                  Optional
                                    { fsType : Optional Text, pdID : Text }
                              , portworxVolume :
                                  Optional
                                    { fsType : Optional Text
                                    , readOnly : Optional Bool
                                    , volumeID : Text
                                    }
                              , projected :
                                  Optional
                                    { defaultMode : Optional Natural
                                    , sources :
                                        List
                                          { configMap :
                                              Optional
                                                { items :
                                                    Optional
                                                      ( List
                                                          { key : Text
                                                          , mode :
                                                              Optional Natural
                                                          , path : Text
                                                          }
                                                      )
                                                , name : Optional Text
                                                , optional : Optional Bool
                                                }
                                          , downwardAPI :
                                              Optional
                                                { items :
                                                    Optional
                                                      ( List
                                                          { fieldRef :
                                                              Optional
                                                                { apiVersion :
                                                                    Optional
                                                                      Text
                                                                , fieldPath :
                                                                    Text
                                                                }
                                                          , mode :
                                                              Optional Natural
                                                          , path : Text
                                                          , resourceFieldRef :
                                                              Optional
                                                                { containerName :
                                                                    Optional
                                                                      Text
                                                                , divisor :
                                                                    Optional
                                                                      Text
                                                                , resource :
                                                                    Text
                                                                }
                                                          }
                                                      )
                                                }
                                          , secret :
                                              Optional
                                                { items :
                                                    Optional
                                                      ( List
                                                          { key : Text
                                                          , mode :
                                                              Optional Natural
                                                          , path : Text
                                                          }
                                                      )
                                                , name : Optional Text
                                                , optional : Optional Bool
                                                }
                                          , serviceAccountToken :
                                              Optional
                                                { audience : Optional Text
                                                , expirationSeconds :
                                                    Optional Natural
                                                , path : Text
                                                }
                                          }
                                    }
                              , quobyte :
                                  Optional
                                    { group : Optional Text
                                    , readOnly : Optional Bool
                                    , registry : Text
                                    , tenant : Optional Text
                                    , user : Optional Text
                                    , volume : Text
                                    }
                              , rbd :
                                  Optional
                                    { fsType : Optional Text
                                    , image : Text
                                    , keyring : Optional Text
                                    , monitors : List Text
                                    , pool : Optional Text
                                    , readOnly : Optional Bool
                                    , secretRef :
                                        Optional { name : Optional Text }
                                    , user : Optional Text
                                    }
                              , scaleIO :
                                  Optional
                                    { fsType : Optional Text
                                    , gateway : Text
                                    , protectionDomain : Optional Text
                                    , readOnly : Optional Bool
                                    , secretRef : { name : Optional Text }
                                    , sslEnabled : Optional Bool
                                    , storageMode : Optional Text
                                    , storagePool : Optional Text
                                    , system : Text
                                    , volumeName : Optional Text
                                    }
                              , secret :
                                  Optional
                                    { defaultMode : Optional Natural
                                    , items :
                                        Optional
                                          ( List
                                              { key : Text
                                              , mode : Optional Natural
                                              , path : Text
                                              }
                                          )
                                    , optional : Optional Bool
                                    , secretName : Optional Text
                                    }
                              , storageos :
                                  Optional
                                    { fsType : Optional Text
                                    , readOnly : Optional Bool
                                    , secretRef :
                                        Optional { name : Optional Text }
                                    , volumeName : Optional Text
                                    , volumeNamespace : Optional Text
                                    }
                              , vsphereVolume :
                                  Optional
                                    { fsType : Optional Text
                                    , storagePolicyID : Optional Text
                                    , storagePolicyName : Optional Text
                                    , volumePath : Text
                                    }
                              }
                          )
                    }
                  }
                }
              , status =
                  None
                    { availableReplicas : Optional Natural
                    , collisionCount : Optional Natural
                    , conditions :
                        Optional
                          ( List
                              { lastTransitionTime : Optional Text
                              , lastUpdateTime : Optional Text
                              , message : Optional Text
                              , reason : Optional Text
                              , status : Text
                              , type : Text
                              }
                          )
                    , observedGeneration : Optional Natural
                    , readyReplicas : Optional Natural
                    , replicas : Optional Natural
                    , unavailableReplicas : Optional Natural
                    , updatedReplicas : Optional Natural
                    }
              }

        in  deployment

let Generate =
        ( λ(c : Configuration/global.Type) →
            { BundleManager =
              { Deployment = BundleManager/Deployment/generate c
              , PersistentVolumeClaim =
                  BundleManager/PersistentVolumeClaim/generate c
              , Service = BundleManager/Service/generate c
              }
            , Worker =
              { Deployment = Worker/Deployment/generate c
              , Service = Worker/Service/generate c
              }
            }
        )
      : ∀(c : Configuration/global.Type) → component

let ToList =
        ( λ(c : component) →
            Kubernetes/List::{
            , items =
              [ Kubernetes/TypesUnion.Deployment c.BundleManager.Deployment
              , Kubernetes/TypesUnion.Service c.BundleManager.Service
              , Kubernetes/TypesUnion.PersistentVolumeClaim
                  c.BundleManager.PersistentVolumeClaim
              , Kubernetes/TypesUnion.Deployment c.Worker.Deployment
              , Kubernetes/TypesUnion.Service c.Worker.Service
              ]
            }
        )
      : ∀(c : component) → Kubernetes/List.Type

let Render =
        (λ(c : Configuration/global.Type) → ToList (Generate c))
      : ∀(c : Configuration/global.Type) → Kubernetes/List.Type

in  Render
