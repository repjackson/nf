if Meteor.isClient
    Router.route '/events', (->
        @layout 'layout'
        @render 'events'
        ), name:'events'

    Template.events.onCreated ->
        @autorun -> Meteor.subscribe('event_facet_docs',
            # selected_event_tags.array()
            # Session.get('selected_school_id')
            # Session.get('sort_key')
        )

    Template.events.helpers
        events: ->
            Docs.find {
                model:'event'
            }, _timestamp:1


    Template.events.events
        'click .add_event': ->
            new_event_id =
                Docs.insert
                    model:'event'
            Session.set 'editing', new_event_id

        'click .edit': ->
            Session.set 'editing_id', @_id
        'click .save': ->
            Session.set 'editing_id', null



# if Meteor.isClient
#     Template.event_cloud.onCreated ->
#         @autorun -> Meteor.subscribe('event_tags',
#             selected_event_tags.array()
#             Session.get('selected_target_id')
#             )
#         # @autorun -> Meteor.subscribe('model_docs', 'target')

#     Template.event_cloud.helpers
#         targets: ->
#             Meteor.users.find
#                 admin:true
#         selected_target_id: -> Session.get('selected_target_id')
#         selected_target: ->
#             Docs.findOne Session.get('selected_target_id')
#         all_event_tags: ->
#             event_count = Docs.find(model:'event').count()
#             if 0 < event_count < 3 then Task_tags.find { count: $lt: event_count } else Task_tags.find({},{limit:42})
#         selected_event_tags: -> selected_event_tags.array()
#     # Template.sort_item.events
#     #     'click .set_sort': ->
#     #         console.log @
#     #         Session.set 'sort_key', @key

#     Template.event_cloud.events
#         'click .unselect_target': -> Session.set('selected_target_id',null)
#         'click .select_target': -> Session.set('selected_target_id',@_id)
#         'click .select_event_tag': -> selected_event_tags.push @name
#         'click .unselect_event_tag': -> selected_event_tags.remove @valueOf()
#         'click #clear_event_tags': -> selected_event_tags.clear()

if Meteor.isServer
    Meteor.publish 'event_tags', (selected_event_tags, selected_target_id)->
        # user = Meteor.users.finPdOne @userId
        # current_herd = user.profile.current_herd
        self = @
        match = {}

        if selected_target_id
            match.target_id = selected_target_id
        # selected_event_tags.push current_herd

        if selected_event_tags.length > 0 then match.tags = $all: selected_event_tags
        match.model = 'event'
        cloud = Docs.aggregate [
            { $match: match }
            { $project: tags: 1 }
            { $unwind: "$tags" }
            { $group: _id: '$tags', count: $sum: 1 }
            { $match: _id: $nin: selected_event_tags }
            { $sort: count: -1, _id: 1 }
            { $limit: 20 }
            { $project: _id: 0, name: '$_id', count: 1 }
            ]

        cloud.forEach (tag, i) ->
            self.added 'event_tags', Random.id(),
                name: tag.name
                count: tag.count
                index: i

        self.ready()


    Meteor.publish 'event_facet_docs', (selected_event_tags, selected_target_id)->
        # user = Meteor.users.findOne @userId
        console.log selected_event_tags
        # console.log filter
        self = @
        match = {}
        if selected_target_id
            match.target_id = selected_target_id


        # if filter is 'shop'
        #     match.active = true
        if selected_event_tags.length > 0 then match.tags = $all: selected_event_tags
        match.model = 'event'
        Docs.find match, sort:_timestamp:-1
