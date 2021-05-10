if Meteor.isClient
    Router.route '/dishes', (->
        @layout 'layout'
        @render 'dishes'
        ), name:'dishes'


    Template.dishes.onCreated ->
        Session.setDefault 'view_mode', 'list'
        Session.setDefault 'dish_sort_key', 'datetime_available'
        Session.setDefault 'dish_sort_label', 'available'
        Session.setDefault 'dish_limit', 5
        Session.setDefault 'view_open', true

    Template.dishes.onCreated ->
        @autorun => @subscribe 'dish_facets',
            selected_ingredients.array()
            Session.get('dish_limit')
            Session.get('dish_sort_key')
            Session.get('dish_sort_direction')
            Session.get('view_delivery')
            Session.get('view_pickup')
            Session.get('view_open')

        @autorun => @subscribe 'dish_results',
            selected_ingredients.array()
            Session.get('dish_limit')
            Session.get('dish_sort_key')
            Session.get('dish_sort_direction')
            Session.get('view_delivery')
            Session.get('view_pickup')
            Session.get('view_open')
            Session.get('dish_query')
            


    Template.dishes.events
        'click .add_dish': ->
            new_id =
                Docs.insert
                    model:'dish'
            Router.go("/dish/#{new_id}/edit")


        'click .toggle_delivery': -> Session.set('view_delivery', !Session.get('view_delivery'))
        'click .toggle_pickup': -> Session.set('view_pickup', !Session.get('view_pickup'))
        'click .toggle_open': -> Session.set('view_open', !Session.get('view_open'))

        'click .ingredient_result': -> selected_ingredients.push @title
        'click .unselect_ingredient': ->
            selected_ingredients.remove @valueOf()
            # console.log selected_ingredients.array()
            # if selected_ingredients.array().length is 1
                # Meteor.call 'call_wiki', search, ->

            # if selected_ingredients.array().length > 0
                # Meteor.call 'search_reddit', selected_ingredients.array(), ->

        'click .clear_selected_ingredients': ->
            Session.set('dish_query',null)
            selected_ingredients.clear()

        'keyup #search': _.throttle((e,t)->
            query = $('#search').val()
            Session.set('dish_query', query)
            # console.log Session.get('dish_query')
            if e.which is 13
                search = $('#search').val().trim().toLowerCase()
                if search.length > 0
                    selected_tags.push search
                    console.log 'search', search
                    # Meteor.call 'log_term', search, ->
                    $('#search').val('')
                    Session.set('dish_query', null)
                    # # $('#search').val('').blur()
                    # # $( "p" ).blur();
                    # Meteor.setTimeout ->
                    #     Session.set('dummy', !Session.get('dummy'))
                    # , 10000
        , 1000)

        'click .calc_dish_count': ->
            Meteor.call 'calc_dish_count', ->

        # 'keydown #search': _.throttle((e,t)->
        #     if e.which is 8
        #         search = $('#search').val()
        #         if search.length is 0
        #             last_val = selected_tags.array().slice(-1)
        #             console.log last_val
        #             $('#search').val(last_val)
        #             selected_tags.pop()
        #             Meteor.call 'search_reddit', selected_tags.array(), ->
        # , 1000)

        'click .reconnect': ->
            Meteor.reconnect()


        'click .set_sort_direction': ->
            if Session.get('dish_sort_direction') is -1
                Session.set('dish_sort_direction', 1)
            else
                Session.set('dish_sort_direction', -1)


    Template.dishes.helpers
        quickbuying_dish: ->
            Docs.findOne Session.get('quickbuying_id')

        sorting_up: ->
            parseInt(Session.get('dish_sort_direction')) is 1

        toggle_delivery_class: -> if Session.get('view_delivery') then 'blue' else ''
        toggle_pickup_class: -> if Session.get('view_pickup') then 'blue' else ''
        toggle_open_class: -> if Session.get('view_open') then 'blue' else ''
        connection: ->
            console.log Meteor.status()
            Meteor.status()
        connected: ->
            Meteor.status().connected
        invert_class: ->
            if Meteor.user()
                if Meteor.user().dark_mode
                    'invert'
        tags: ->
            # if Session.get('dish_query') and Session.get('dish_query').length > 1
            #     Terms.find({}, sort:count:-1)
            # else
            dish_count = Docs.find().count()
            # console.log 'dish count', dish_count
            if dish_count < 3
                Tags.find({count: $lt: dish_count})
            else
                Tags.find()

        ingredients: ->
            # if Session.get('dish_query') and Session.get('dish_query').length > 1
            #     Terms.find({}, sort:count:-1)
            # else
            dish_count = Docs.find().count()
            # console.log 'dish count', dish_count
            if dish_count < 3
                Ingredients.find({count: $lt: dish_count})
            else
                Ingredients.find()

        result_class: ->
            if Template.instance().subscriptionsReady()
                ''
            else
                'disabled'

        selected_ingredients: -> selected_ingredients.array()
        selected_ingredients_plural: -> selected_ingredients.array().length > 1
        searching: -> Session.get('searching')

        one_post: ->
            Docs.find().count() is 1
        dish_docs: ->
            # if selected_ingredients.array().length > 0
            Docs.find {
                model:'dish'
            },
                sort: "#{Session.get('dish_sort_key')}":parseInt(Session.get('dish_sort_direction'))
                limit:Session.get('dish_limit')

        home_subs_ready: ->
            Template.instance().subscriptionsReady()
        users: ->
            # if selected_tags.array().length > 0
            Meteor.users.find {
            },
                sort: count:-1
                # limit:1


        timestamp_tags: ->
            # if selected_tags.array().length > 0
            Timestamp_tags.find {
                # model:'reddit'
            },
                sort: count:-1
                # limit:1

        dish_limit: ->
            Session.get('dish_limit')

        current_dish_sort_label: ->
            Session.get('dish_sort_label')


    # Template.set_dish_limit.events
    #     'click .set_limit': ->
    #         console.log @
    #         Session.set('dish_limit', @amount)

    Template.set_dish_sort_key.events
        'click .set_sort': ->
            console.log @
            Session.set('dish_sort_key', @key)
            Session.set('dish_sort_label', @label)



if Meteor.isServer
    Meteor.publish 'dish_results', (
        selected_ingredients
        doc_limit
        doc_sort_key
        doc_sort_direction
        view_delivery
        view_pickup
        view_open
        dish_query
        )->
        # console.log selected_ingredients
        if doc_limit
            limit = doc_limit
        else
            limit = 10
        if doc_sort_key
            sort_key = doc_sort_key
        if doc_sort_direction
            sort_direction = parseInt(doc_sort_direction)
        self = @
        match = {model:'dish', app:'lfc'}
        if view_open
            match.open = $ne:false
        if view_delivery
            match.delivery = $ne:false
        if view_pickup
            match.pickup = $ne:false
        if selected_ingredients.length > 0
            match.ingredients = $all: selected_ingredients
            sort = 'price_per_serving'
        else
            # match.tags = $nin: ['wikipedia']
            sort = '_timestamp'
            # match.source = $ne:'wikipedia'
        # if view_images
        #     match.is_image = $ne:false
        # if view_videos
        #     match.is_video = $ne:false

        # match.tags = $all: selected_ingredients
        # if filter then match.model = filter
        # keys = _.keys(prematch)
        # for key in keys
        #     key_array = prematch["#{key}"]
        #     if key_array and key_array.length > 0
        #         match["#{key}"] = $all: key_array
            # console.log 'current facet filter array', current_facet_filter_array

        console.log 'dish match', match
        console.log 'sort key', sort_key
        console.log 'sort direction', sort_direction
        Docs.find match,
            sort:"#{sort_key}":sort_direction
            # sort:_timestamp:-1
            limit: limit

    Meteor.publish 'dish_facets', (
        selected_ingredients
        selected_timestamp_tags
        query
        doc_limit
        doc_sort_key
        doc_sort_direction
        view_delivery
        view_pickup
        view_open
        )->
        # console.log 'dummy', dummy
        # console.log 'query', query
        console.log 'selected ingredients', selected_ingredients

        self = @
        match = {app:'lfc'}
        match.model = 'dish'
        if view_open
            match.open = $ne:false
        if view_delivery
            match.delivery = $ne:false
        if view_pickup
            match.pickup = $ne:false
        if selected_ingredients.length > 0 then match.ingredients = $all: selected_ingredients
            # match.$regex:"#{dish_query}", $options: 'i'}
        # if query and query.length > 1
        # #     console.log 'searching query', query
        # #     # match.tags = {$regex:"#{query}", $options: 'i'}
        # #     # match.tags_string = {$regex:"#{query}", $options: 'i'}
        # #
        #     Terms.find {
        #         title: {$regex:"#{query}", $options: 'i'}
        #     },
        #         sort:
        #             count: -1
        #         limit: 20
            # tag_cloud = Docs.aggregate [
            #     { $match: match }
            #     { $project: "tags": 1 }
            #     { $unwind: "$tags" }
            #     { $group: _id: "$tags", count: $sum: 1 }
            #     { $match: _id: $nin: selected_ingredients }
            #     { $match: _id: {$regex:"#{query}", $options: 'i'} }
            #     { $sort: count: -1, _id: 1 }
            #     { $limit: 42 }
            #     { $project: _id: 0, name: '$_id', count: 1 }
            #     ]

        # else
        # unless query and query.length > 2
        # if selected_ingredients.length > 0 then match.tags = $all: selected_ingredients
        # # match.tags = $all: selected_ingredients
        # # console.log 'match for tags', match
        # tag_cloud = Docs.aggregate [
        #     { $match: match }
        #     { $project: "tags": 1 }
        #     { $unwind: "$tags" }
        #     { $group: _id: "$tags", count: $sum: 1 }
        #     { $match: _id: $nin: selected_ingredients }
        #     # { $match: _id: {$regex:"#{dish_query}", $options: 'i'} }
        #     { $sort: count: -1, _id: 1 }
        #     { $limit: 20 }
        #     { $project: _id: 0, name: '$_id', count: 1 }
        # ], {
        #     allowDiskUse: true
        # }
        #
        # tag_cloud.forEach (tag, i) =>
        #     # console.log 'queried tag ', tag
        #     # console.log 'key', key
        #     self.added 'tags', Random.id(),
        #         title: tag.name
        #         count: tag.count
        #         # category:key
        #         # index: i


        ingredient_cloud = Docs.aggregate [
            { $match: match }
            { $project: "ingredients": 1 }
            { $unwind: "$ingredients" }
            { $group: _id: "$ingredients", count: $sum: 1 }
            { $sort: count: -1, _id: 1 }
            { $limit: 20 }
            { $project: _id: 0, title: '$_id', count: 1 }
        ], {
            allowDiskUse: true
        }

        ingredient_cloud.forEach (ingredient, i) =>
            # console.log 'ingredient result ', ingredient
            self.added 'ingredients', Random.id(),
                title: ingredient.title
                count: ingredient.count
                # category:key
                # index: i


        self.ready()





if Meteor.isClient
    Template.dish_card.onCreated ->
        # @autorun => Meteor.subscribe 'model_docs', 'food'
    Template.dish_card.events
        'click .quickbuy': ->
            console.log @
            Session.set('quickbuying_id', @_id)
            # $('.ui.dimmable')
            #     .dimmer('show')
            # $('.special.cards .image').dimmer({
            #   on: 'hover'
            # });
            # $('.card')
            #   .dimmer('toggle')
            $('.ui.modal')
              .modal('show')

        'click .goto_food': (e,t)->
            # $(e.currentTarget).closest('.card').transition('zoom',200)
            # $('.global_container').transition('scale', 500)
            Router.go("/food/#{@_id}")
            # Meteor.setTimeout =>
            # , 100

        # 'click .view_card': ->
        #     $('.container_')

    Template.dish_card.helpers
        dish_card_class: ->
            # if Session.get('quickbuying_id')
            #     if Session.equals('quickbuying_id', @_id)
            #         'raised'
            #     else
            #         'active medium dimmer'
        is_quickbuying: ->
            Session.equals('quickbuying_id', @_id)

        food: ->
            # console.log Meteor.user().roles
            Docs.find {
                model:'food'
            }, sort:title:1
