Meteor.methods
    create_chat: (tags=[])->
        Docs.insert
            tags: tags
            model: 'chat'
            subscribers: [Meteor.userId()]
            participant_ids: [Meteor.userId()]
        # Router.go "/chat/#{id}"

    close_chat: (chat_id)->
        Docs.remove chat_id
        Docs.remove
            model: 'message'
            classroom_id: chat_id

    join_chat: (chat_id)->
        Docs.update chat_id,
            $addToSet:
                participant_ids: Meteor.userId()

    leave_chat: (chat_id)->
        Docs.update chat_id,
            $pull:
                participant_ids: Meteor.userId()



if Meteor.isClient
    Template.view_chats.onCreated ->
        @autorun -> Meteor.subscribe('chats', selected_theme_tags.array(), selected_participant_ids.array())
        @view_published = new ReactiveVar(true)

    Template.view_chats.helpers
        chats: ->
            if Template.instance().view_published.get() is true
                Docs.find {
                    model: 'chat'
                    published: true
                }, sort: timestamp: -1
            else
                Docs.find {
                    participant_ids: $in: [Meteor.userId()]
                    model: 'chat'
                    published: -1
                }, sort: timestamp: -1

        selected_chat: ->
            Docs.findOne Session.get 'current_chat_id'

        unread_message_count: ->
            count = 0
            my_chats = Docs.find(
                model: 'chat'
                participant_ids: $in: [Meteor.userId()]
            ).fetch()

            for chat in my_chats
                unread_count = Docs.find(
                    model: 'message'
                    classroom_id: chat._id
                    read_ids: $nin: [Meteor.userId()]
                ).count()
                count += unread_count
            count


        viewing_published: -> Template.instance().view_published.get() is true
        viewing_private: -> Template.instance().view_published.get() is false



    Template.view_chats.events
        'click #create_chat': ->
            Meteor.call 'create_chat', (err,id)->
                Session.set 'current_chat_id', id

        'click #create_dm': ->
            Meteor.call 'create_', (err,id)->
                Session.set 'current_chat_id', id

                # Router.go "/view/#{id}"


    # 'click #create_chat': ->
    #     id = Docs.insert
    #         model: 'chat'
    #         participant_ids: [Meteor.userId()]
    #     Router.go "/chat/#{id}"


        'click #view_private_chats': (e,t)->
            t.view_published.set(false)

        'click #view_published_chats': (e,t)->
            t.view_published.set(true)





if Meteor.isServer
    Meteor.publish 'people_list', (chat_id) ->
        chat = Docs.findOne chat_id
        Meteor.users.find
            _id: $in: chat.participant_ids


    # Meteor.publish 'chat_messages', (chat_id) ->
    #     Docs.find
    #         model: 'message'
    #         chat_id: chat_id


    publishComposite 'participant_ids', (selected_theme_tags, selected_participant_ids)->

        {
            find: ->
                self = @
                match = {}
                match.model = 'chat'
                if selected_theme_tags.length > 0 then match.tags = $all: selected_theme_tags
                if selected_participant_ids.length > 0 then match.participant_ids = $in: selected_participant_ids
                match.published = true

                cloud = Docs.aggregate [
                    { $match: match }
                    { $project: participant_ids: 1 }
                    { $unwind: "$participant_ids" }
                    { $group: _id: '$participant_ids', count: $sum: 1 }
                    { $match: _id: $nin: selected_participant_ids }
                    { $sort: count: -1, _id: 1 }
                    { $limit: 20 }
                    { $project: _id: 0, text: '$_id', count: 1 }
                    ]



                # author_objects = []
                # Meteor.users.find _id: $in: cloud.

                cloud.forEach (participant_ids) ->
                    self.added 'participant_ids', Random.id(),
                        text: participant_ids.text
                        count: participant_ids.count
                self.ready()

            # children: [
            #     { find: (doc) ->
            #         Meteor.users.find
            #             _id: doc.participant_ids
            #         }
            #     ]
        }


    Meteor.publish 'chats', (selected_theme_tags, selected_participant_ids, view_published)->

        self = @
        match = {}
        if selected_theme_tags.length > 0 then match.tags = $all: selected_theme_tags
        if view_published is true
            match.published = 1
            if selected_participant_ids.length > 0 then match.participant_ids = $in: selected_participant_ids
        else if view_published = false
            match.published = -1
            selected_participant_ids.push Meteor.userId()
            match.participant_ids = $in: selected_participant_ids
        # if view_mode
        #     if view_mode is 'mine'
        #         match
        #         match.participant_ids = $in: [Meteor.userId()]
        # else
            # if selected_participant_ids.length > 0 then match.participant_ids = $in: selected_participant_ids


        match.model = 'chat'

        cursor = Docs.find match
        return cursor