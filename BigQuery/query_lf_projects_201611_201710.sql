#this is a query for data that goes into The Linux Foundation chart - last year's worth
SELECT
  org,
  repo,
  sum(activity) AS activity,
  sum(comments) AS comments,
  sum(prs) AS prs,
  sum(commits) AS commits,
  sum(issues) AS issues,
  EXACT_COUNT_DISTINCT(author_email) AS authors_alt2,
  GROUP_CONCAT(STRING(author_name)) AS authors_alt1,
  GROUP_CONCAT(STRING(author_email)) AS authors
FROM (
SELECT
  org.login AS org,
  repo.name AS repo,
  count(*) AS activity,
  SUM(IF(type = 'IssueCommentEvent', 1, 0)) AS comments,
  SUM(IF(type = 'PullRequestEvent', 1, 0)) AS prs,
  SUM(IF(type = 'PushEvent', 1, 0)) AS commits,
  SUM(IF(type = 'IssuesEvent', 1, 0)) AS issues,
  IFNULL(REPLACE(JSON_EXTRACT(payload, '$.commits[0].author.email'), '"', ''), '(null)') AS author_email,
  IFNULL(REPLACE(JSON_EXTRACT(payload, '$.commits[0].author.name'), '"', ''), '(null)') AS author_name
FROM 
  (SELECT * from
    TABLE_DATE_RANGE([githubarchive:day.],TIMESTAMP('2016-11-01'),TIMESTAMP('2017-10-31'))
  )
WHERE
  (
    org.login IN (
      'alljoyn','cip-project','cloudfoundry','cncf','codeaurora-unofficial','coreinfrastructure','Dronecode',
      'edgexafoundry','fdio-stack','fluent','fossology','frrouting','grpc','hyperledger','iovisor','iotivity',
      'JSFoundation','Kinetic','kubernetes','letsencrypt','linkerd','LinuxStandardBase','nodejs','odpi','OAI',
      'opencontainers','openmainframeproject','opensecuritycontroller','openvswitch','openchain','opendaylight',
      'openhpc','OpenMAMA','opensds','open-switch','opentracing','opnfv','pndaproject','prometheus','RConsortium',
      'rethinkdb','SNAS','spdx','todogroup','xen-project','zephyrproject-rtos'
    )
    OR repo.name IN ('automotive-grade-linux/docs-agl','joeythesaint/cgl-specification',
    'containernetworking/cni','containerd/containerd','opencord/cord','cncf/cross-cloud',
    'cregit/cregit','diamon/diamon-www-data','JanusGraph/janusgraph','opennetworkinglab/onos',
    'brunopulis/awesome-a11y','obrienlabs/onap-root','ni/linux','rkt/rkt','Samsung/TizenRT'
    )
  )
  AND type IN ('IssueCommentEvent', 'PullRequestEvent', 'PushEvent', 'IssuesEvent')
  AND actor.login NOT LIKE '%bot%'
  AND actor.login NOT IN (
  'CF MEGA BOT','CAPI CI','CF Buildpacks Team CI Server','CI Pool Resource','I am Groot CI','CI (automated)','Loggregator CI','CI (Automated)','CI Bot','cf-infra-bot','CI','cf-loggregator','bot','CF INFRASTRUCTURE BOT','CF Garden','Container Networking Bot','Routing CI (Automated)','CF-Identity','BOSH CI','CF Loggregator CI Pipeline','CF Infrastructure','CI Submodule AutoUpdate','routing-ci','Concourse Bot','CF Toronto CI Bot','Concourse CI','Pivotal Concourse Bot','RUNTIME OG CI','CF CredHub CI Pipeline','CF CI Pipeline','CF Identity','PCF Security Enablement CI','CI BOT','Cloudops CI','hcf-bot','Cloud Foundry Buildpacks Team Robot','CF CORE SERVICES BOT','PCF Security Enablement','fizzy bot','Appdog CI Bot','CF Tribe','Greenhouse CI','fabric-composer-app','iotivity-replication','SecurityTest456','odl-github','opnfv-github' 
  )
  AND actor.login NOT IN (
    SELECT
      actor.login
    FROM (
      SELECT
        actor.login,
        COUNT(*) c
      FROM
        TABLE_DATE_RANGE([githubarchive:day.],TIMESTAMP('2016-11-01'),TIMESTAMP('2017-10-31'))
      WHERE
        type = 'IssueCommentEvent'
      GROUP BY
        1
      HAVING
        c > 5000
      ORDER BY
      2 DESC
    )
  )
GROUP BY org, repo, author_email, author_name
)
GROUP BY org, repo
HAVING 
  authors_alt2 > 5
  AND comments > 50
  AND prs > 20
  AND commits > 20
AND issues > 20
ORDER BY activity DESC
;

