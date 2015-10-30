# SERVER AND CLIENT
Messages = new Mongo.Collection "messages"

# CLIENT ONLY
if Meteor.isClient
  # Subscriptions
  # Meteor.subscribe "allmessages"
  Tracker.autorun ->
    if Meteor.user
      Session.set "room", "general"
      Meteor.subscribe "allMessages", Session.get("room")

  # Template Helpers
  Template.chatbox.helpers
    user: Meteor.user
    noMessages: -> Messages.find({}).count() is 0
    messages: -> Messages.find {}, sort: createdAt: -1

  Template.message.helpers
    ago: -> moment(this.createdAt).fromNow()

  # Template Events
  Template.chatbox.events
    "submit #message": (event) ->
      event.preventDefault()
      Messages.insert
        room: Session.get("room")
        text: $('#text').val()
      $('#text').val('')

    "submit #room": (event) ->
      event.preventDefault()
      Session.set "room", $("#roomName").val()

# SERVER ONLY
if Meteor.isServer
  Accounts.onCreateUser (options, user) ->
    user.profile = name: user.services.github.username
    user

  Meteor.publish "allMessages", (room) ->
    Messages.find(if room then {room} else {})

  Messages.allow
    insert: (userId, document) ->
      check document,
        room: String
        text: String
      document.createdAt = moment().valueOf()
      document.username = Meteor.users.findOne(userId).profile.name
      document.text.length > 0

