# Description:
#   Q&A Bot

Firebase = require 'firebase'

questionsRef = new Firebase 'https://boiling-heat-7286.firebaseio.com/questions'

questionsRef.authWithCustomToken 'YOUR_TOKEN_HERE', ->
  return console.log err if err?
  console.log 'Authenticated to Firebase'

createReply = (body, meta) ->
  message: body
  user: meta.user.name
  room: meta.room
  created: Date.now()

module.exports = (robot) ->

  questions = []

  # Question route
  robot.hear /^#q (.*)/, (data) ->

    question = createReply data.match[1], data.message

    newRef = questionsRef.push question, (err) ->

      if err?
        console.log err
        data.reply "Kysymystä ei voitu tallentaa."
        return

      id = questions.push(newRef.key()) - 1
      data.send "Kysymys ##{id} luotu."

  # Answer route
  robot.hear /^#(\d+) (.*)/, (data) ->
    {match} = data

    id = parseInt match[1]

    question = questions[id]

    unless question?
      data.reply "Kysymystä ##{id} ei ole olemassa."
      return

    reply = createReply match[2], data.message
    replies = questionsRef.child(question).child('replies')

    replies.push reply, (err) ->
      return unless err?
      data.reply "Vastausta ei voitu tallentaa."
      console.log err
