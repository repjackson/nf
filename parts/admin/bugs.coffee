if Meteor.isClient
    Router.route '/bugs', (->
        @layout 'admin_layout'
        @render 'bugs'
        ), name:'bugs'

    Template.bugs.onCreated ->
        @autorun -> Meteor.subscribe('bug_facet_docs',
            selected_bug_tags.array()
            # Session.get('selected_school_id')
            # Session.get('sort_key')
        )

    Template.bugs.helpers
        bugs: ->
            Docs.find {
                model:'bug'
            }, _timestamp:1


    Template.bugs.events
        'click .add_bug': ->
            new_bug_id =
                Docs.insert
                    model:'bug'
            Session.set 'editing', new_bug_id

        'click .edit': ->
            Session.set 'editing_id', @_id
        'click .save': ->
            Session.set 'editing_id', null



if Meteor.isClient
    Template.bug_cloud.onCreated ->
        @autorun -> Meteor.subscribe('bug_tags',
            selected_bug_tags.array()
            Session.get('selected_target_id')
            )
        # @autorun -> Meteor.subscribe('model_docs', 'target')

    Template.bug_cloud.helpers
        targets: ->
            Meteor.users.find
                admin:true
        selected_target_id: -> Session.get('selected_target_id')
        selected_target: ->
            Docs.findOne Session.get('selected_target_id')
        all_bug_tags: ->
            bug_count = Docs.find(model:'bug').count()
            if 0 < bug_count < 3 then Task_tags.find { count: $lt: bug_count } else Task_tags.find({},{limit:42})
        selected_bug_tags: -> selected_bug_tags.array()
    # Template.sort_item.events
    #     'click .set_sort': ->
    #         console.log @
    #         Session.set 'sort_key', @key

    Template.bug_cloud.events
        'click .unselect_target': -> Session.set('selected_target_id',null)
        'click .select_target': -> Session.set('selected_target_id',@_id)
        'click .select_bug_tag': -> selected_bug_tags.push @name
        'click .unselect_bug_tag': -> selected_bug_tags.remove @valueOf()
        'click #clear_bug_tags': -> selected_bug_tags.clear()

if Meteor.isServer
    Meteor.publish 'bug_tags', (selected_bug_tags, selected_target_id)->
        # user = Meteor.users.finPdOne @userId
        # current_herd = user.profile.current_herd
        self = @
        match = {}

        if selected_target_id
            match.target_id = selected_target_id
        # selected_bug_tags.push current_herd

        if selected_bug_tags.length > 0 then match.tags = $all: selected_bug_tags
        match.model = 'bug'
        cloud = Docs.aggregate [
            { $match: match }
            { $project: tags: 1 }
            { $unwind: "$tags" }
            { $group: _id: '$tags', count: $sum: 1 }
            { $match: _id: $nin: selected_bug_tags }
            { $sort: count: -1, _id: 1 }
            { $limit: 100 }
            { $project: _id: 0, name: '$_id', count: 1 }
            ]

        cloud.forEach (tag, i) ->
            self.added 'bug_tags', Random.id(),
                name: tag.name
                count: tag.count
                index: i

        self.ready()


    Meteor.publish 'bug_facet_docs', (selected_bug_tags, selected_target_id)->
        # user = Meteor.users.findOne @userId
        console.log selected_bug_tags
        # console.log filter
        self = @
        match = {}
        if selected_target_id
            match.target_id = selected_target_id


        # if filter is 'shop'
        #     match.active = true
        if selected_bug_tags.length > 0 then match.tags = $all: selected_bug_tags
        match.model = 'bug'
        Docs.find match, sort:_timestamp:-1
