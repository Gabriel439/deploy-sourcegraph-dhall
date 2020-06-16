let kubernetes = (../../imports.dhall).Kubernetes

let prelude = (../../imports.dhall).Prelude

let Optional/default = prelude.Optional.default

let Configuration/global = ../../configuration/global.dhall

let util = ../../util.dhall

let render =
      λ(c : Configuration/global.Type) →
        let overrides = c.Frontend.RoleBinding

        let additionalLabels =
              Optional/default
                (List util.keyValuePair)
                ([] : List util.keyValuePair)
                overrides.additionalLabels

        let roleBinding =
              kubernetes.RoleBinding::{
              , metadata = kubernetes.ObjectMeta::{
                , labels = Some
                    (   [ { mapKey = "category", mapValue = "rbac" }
                        , { mapKey = "deploy", mapValue = "sourcegraph" }
                        , { mapKey = "sourcegraph-resource-requires"
                          , mapValue = "cluster-admin"
                          }
                        ]
                      # additionalLabels
                    )
                , namespace = overrides.namespace
                , name = Some "sourcegraph-frontend"
                }
              , roleRef = kubernetes.RoleRef::{
                , apiGroup = ""
                , kind = "Role"
                , name = "sourcegraph-frontend"
                }
              , subjects = Some
                [ kubernetes.Subject::{
                  , kind = "ServiceAccount"
                  , name = "sourcegraph-frontend"
                  }
                ]
              }

        in  roleBinding

in  render
