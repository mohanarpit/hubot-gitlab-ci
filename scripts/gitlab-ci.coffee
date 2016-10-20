# Description:
#   Gitlab build trigger
#
# Notes:
#   These are from the scripting documentation: https://github.com/github/hubot/blob/master/docs/scripting.md

module.exports = (robot) ->

  robot.hear /gitlab build (.*)$/i, (res) ->
    res.send "Building ..."
    project_name = res.match[1]
    gitlab_ci_token = process.env.GITLAB_CI_TOKEN
    res.send "Will build #{project_name} using key #{gitlab_ci_token}"

    res.http("https://code.usefilter.com/api/v3/projects?private_token=#{gitlab_ci_token}")
    .header('Accept', 'application/json')
    .get() (err, http_res, body) ->
      if err
        res.send 'Sorry. Unable to fetch the list of projects from Gitlab'

      project_found = false
      project_id = undefined

      for project in JSON.parse body
        if project.name.toLowerCase()  is project_name.toLowerCase()
            project_found = true
            project_id = project.id
            res.send "Found project with ID: #{project.id}"

      data="token=31fbfd2df8232e109704cb2b4db700&ref=master"
      if project_found
          res.http("https://code.usefilter.com/api/v3/projects/#{project_id}/trigger/builds")
          .header("Content-Type","application/x-www-form-urlencoded")
          .post(data) (err, http_res, body) ->
            if err
              res.send "Error while triggering the build"
              return

            res.send "Triggered the build..."

  robot.hear /gitlab status (.*)$/i, (res) ->
    project_name = res.match[1]
    gitlab_ci_token = process.env.GITLAB_CI_TOKEN

    res.http("https://code.usefilter.com/api/v3/projects?private_token=#{gitlab_ci_token}")
    .header('Accept', 'application/json')
    .get() (err, http_res, body) ->
      if err
        res.send 'Sorry. Unable to fetch the list of projects from Gitlab'

      project_found = false
      project_id = undefined

      for project in JSON.parse body
        if project.name.toLowerCase()  is project_name.toLowerCase()
            project_found = true
            project_id = project.id
            res.send "Found project with ID: #{project.id}"

      res.http("https://code.usefilter.com/api/v3/projects/#{project_id}/repository/commits?private_token=#{gitlab_ci_token}")
      .header('Accept', 'application/json')
      .get() (err, http_res, body) ->
        if err
          res.send 'Sorry. Unable to fetch the list of commits from Gitlab'

        commits = JSON.parse body
        commit = commits[0]
        res.send "Fetching status for: #{commit.id}"
        res.http("https://code.usefilter.com/api/v3/projects/2/repository/commits/#{commit.id}/statuses?private_token=#{gitlab_ci_token}")
        .header('Accept', 'application/json')
        .get() (err, http_res, body) ->
          if err
            res.send 'Sorry. Unable to fetch commit status from Gitlab'

          builds = JSON.parse body
          res.send "The last build was #{builds[0].status}"
          if builds[0].status is "success"
            res.emote ":sparkler:"
          else
            res.emote ":cry:"

  # lulz = ['lol', 'rofl', 'lmao']
  #
  # robot.respond /lulz/i, (res) ->
  #   res.send res.random lulz
  #
  # robot.topic (res) ->
  #   res.send "#{res.message.text}? That's a Paddlin'"
  #
  #
  # enterReplies = ['Hi', 'Target Acquired', 'Firing', 'Hello friend.', 'Gotcha', 'I see you']
  # leaveReplies = ['Are you still there?', 'Target lost', 'Searching']
  #
  # robot.enter (res) ->
  #   res.send res.random enterReplies
  # robot.leave (res) ->
  #   res.send res.random leaveReplies
  #
  # answer = process.env.HUBOT_ANSWER_TO_THE_ULTIMATE_QUESTION_OF_LIFE_THE_UNIVERSE_AND_EVERYTHING
  #
  # robot.respond /what is the answer to the ultimate question of life/, (res) ->
  #   unless answer?
  #     res.send "Missing HUBOT_ANSWER_TO_THE_ULTIMATE_QUESTION_OF_LIFE_THE_UNIVERSE_AND_EVERYTHING in environment: please set and try again"
  #     return
  #   res.send "#{answer}, but what is the question?"
  #
  # robot.respond /you are a little slow/, (res) ->
  #   setTimeout () ->
  #     res.send "Who you calling 'slow'?"
  #   , 60 * 1000
  #
  # annoyIntervalId = null
  #
  # robot.respond /annoy me/, (res) ->
  #   if annoyIntervalId
  #     res.send "AAAAAAAAAAAEEEEEEEEEEEEEEEEEEEEEEEEIIIIIIIIHHHHHHHHHH"
  #     return
  #
  #   res.send "Hey, want to hear the most annoying sound in the world?"
  #   annoyIntervalId = setInterval () ->
  #     res.send "AAAAAAAAAAAEEEEEEEEEEEEEEEEEEEEEEEEIIIIIIIIHHHHHHHHHH"
  #   , 1000
  #
  # robot.respond /unannoy me/, (res) ->
  #   if annoyIntervalId
  #     res.send "GUYS, GUYS, GUYS!"
  #     clearInterval(annoyIntervalId)
  #     annoyIntervalId = null
  #   else
  #     res.send "Not annoying you right now, am I?"
  #
  #
  # robot.router.post '/hubot/chatsecrets/:room', (req, res) ->
  #   room   = req.params.room
  #   data   = JSON.parse req.body.payload
  #   secret = data.secret
  #
  #   robot.messageRoom room, "I have a secret: #{secret}"
  #
  #   res.send 'OK'
  #
  # robot.error (err, res) ->
  #   robot.logger.error "DOES NOT COMPUTE"
  #
  #   if res?
  #     res.reply "DOES NOT COMPUTE"
  #
  # robot.respond /have a soda/i, (res) ->
  #   # Get number of sodas had (coerced to a number).
  #   sodasHad = robot.brain.get('totalSodas') * 1 or 0
  #
  #   if sodasHad > 4
  #     res.reply "I'm too fizzy.."
  #
  #   else
  #     res.reply 'Sure!'
  #
  #     robot.brain.set 'totalSodas', sodasHad+1
  #
  # robot.respond /sleep it off/i, (res) ->
  #   robot.brain.set 'totalSodas', 0
  #   res.reply 'zzzzz'
