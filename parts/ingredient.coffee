if Meteor.isClient
    Router.route '/ingredients', (->
        @layout 'layout'
        @render 'ingredients'
        ), name:'ingredients'


    Template.ingredients.onCreated ->
        Session.setDefault 'view_mode', 'grid'
        Session.setDefault 'sort_key', '_timestamp'
        Session.setDefault 'sort_direction', -1
        # Session.setDefault 'ingredient_sort_label', 'complete'
        Session.setDefault 'limit', 42
        Session.setDefault 'view_open', true

    Template.ingredients.onCreated ->
        # @autorun => @subscribe 'model_docs', 'special', ->
        @autorun => @subscribe 'ingredient_facets',
            picked_tags.array()
            Session.get('limit')
            Session.get('sort_key')
            Session.get('sort_direction')
            Session.get('view_delivery')
            Session.get('view_pickup')
            Session.get('view_open')

        @autorun => @subscribe 'ingredient_results',
            picked_tags.array()
            Session.get('limit')
            Session.get('sort_key')
            Session.get('sort_direction')
            Session.get('view_delivery')
            Session.get('view_pickup')
            Session.get('view_open')


    Template.ingredients.events
        'click .add_ingredient': ->
            new_id =
                Docs.insert
                    model:'ingredient'
            Router.go("/ingredient/#{new_id}/edit")

        'click .get_data': ->
            Meteor.call 'get_ingredients', ->
                

        'click .tag_result': -> picked_tags.push @title
        'click .unselect_tag': ->
            picked_tags.remove @valueOf()
            # console.log picked_tags.array()
            # if picked_tags.array().length is 1
                # Meteor.call 'call_wiki', search, ->

            # if picked_tags.array().length > 0
                # Meteor.call 'search_reddit', picked_tags.array(), ->

        'click .clear_picked_tags': ->
            Session.set('current_query',null)
            picked_tags.clear()

        'keyup #search': _.throttle((e,t)->
            query = $('#search').val()
            Session.set('current_query', query)
            # console.log Session.get('current_query')
            if e.which is 13
                search = $('#search').val().trim().toLowerCase()
                if search.length > 0
                    picked_tags.push search
                    console.log 'search', search
                    # Meteor.call 'log_term', search, ->
                    $('#search').val('')
                    Session.set('current_query', null)
                    # # $('#search').val('').blur()
                    # # $( "p" ).blur();
                    # Meteor.setTimeout ->
                    #     Session.set('dummy', !Session.get('dummy'))
                    # , 10000
        , 1000)

        'click .calc_ingredient_count': ->
            Meteor.call 'calc_ingredient_count', ->

        # 'keydown #search': _.throttle((e,t)->
        #     if e.which is 8
        #         search = $('#search').val()
        #         if search.length is 0
        #             last_val = picked_tags.array().slice(-1)
        #             console.log last_val
        #             $('#search').val(last_val)
        #             picked_tags.pop()
        #             Meteor.call 'search_reddit', picked_tags.array(), ->
        # , 1000)




    Template.ingredients.helpers
        special_docs: ->
            Docs.find 
                model:'special'
        quickbuying_ingredient: ->
            Docs.findOne Session.get('quickbuying_id')

        result_class: ->
            if Template.instance().subscriptionsReady()
                ''
            else
                'disabled'

        picked_tags: -> picked_tags.array()
        picked_tags_plural: -> picked_tags.array().length > 1
        searching: -> Session.get('searching')

        one_ingredient: ->
            Docs.find().count() is 1
        ingredient_docs: ->
            # if picked_tags.array().length > 0
            Docs.find {
                model:'ingredient'
            },
                sort: "#{Session.get('sort_key')}":parseInt(Session.get('sort_direction'))
                # limit:Session.get('limit')
                limit:20

        home_subs_ready: ->
            Template.instance().subscriptionsReady()




if Meteor.isServer
    Meteor.methods 
        get_ingredients: ->
            file = JSON.parse(Assets.getText("data.json"));
            # console.log file.ingredients
            for ingredient in file.ingredients
                found_ingredient = 
                    Docs.findOne 
                        model:'ingredient'
                        uuid:ingredient.uuid
                if found_ingredient 
                    console.log 'found ingredient, skipping', ingredient.uuid
                else
                    console.log 'not found for uuid', ingredient.uuid
                    ingredient.model = 'ingredient'
                    ingredient.source = 'demo'
                    console.log 'inserting new doc', ingredient
                    Docs.insert ingredient
                    
            for special in file.specials 
                found_special = 
                    Docs.findOne 
                        model:'special'
                        uuid:special.uuid
                if found_special 
                    console.log 'found special, skipping', special.uuid
                else
                    console.log 'not found for uuid', special.uuid
                    special.model = 'special'
                    special.source = 'demo'
                    console.log 'inserting new doc', special
                    Docs.insert special

                    #   "uuid": "8f730f08-5ea5-48fb-bfd7-6a28337efc28",
                    #   "ingredientId": "aa1ff525-4190-4a66-8d12-3f383a752b55",
                    #   "type": "promocode",
                    #   "code": "GETMILK",
                    #   "title": "$1 off Milk",
                    #   "text": "Use the promocode GETMILK on Peapod and receive $1 off your next gallon!"
                            
    
    Meteor.publish 'ingredient_results', (
        picked_tags=[]
        limit=20
        sort_key='_timestamp'
        sort_direction=-1
        view_delivery
        view_pickup
        view_open
        )->
        # console.log picked_tags
        self = @
        match = {model:'ingredient'}
        # if view_pickup
        #     match.pickup = $ne:false
        if picked_tags.length > 0
            match.tags = $all: picked_tags
            # sort = '_timestamp'
            # match.source = $ne:'wikipedia'
        # if view_images
        #     match.is_image = $ne:false
        # if view_videos
        #     match.is_video = $ne:false

        # match.tags = $all: picked_tags
        # if filter then match.model = filter
        # keys = _.keys(prematch)
        # for key in keys
        #     key_array = prematch["#{key}"]
        #     if key_array and key_array.length > 0
        #         match["#{key}"] = $all: key_array
            # console.log 'current facet filter array', current_facet_filter_array

        Docs.find match,
            sort:"#{sort_key}":sort_direction
            # sort:_timestamp:-1
            limit: 20

    Meteor.publish 'ingredient_facets', (
        picked_tags
        picked_timestamp_tags
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
        console.log 'selected tags', picked_tags

        self = @
        match = {}
        match.model = 'ingredient'
        if view_open
            match.open = $ne:false

        if view_delivery
            match.delivery = $ne:false
        if view_pickup
            match.pickup = $ne:false
        if picked_tags.length > 0 then match.tags = $all: picked_tags
            # match.$regex:"#{current_query}", $options: 'i'}
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
            #     { $match: _id: $nin: picked_tags }
            #     { $match: _id: {$regex:"#{query}", $options: 'i'} }
            #     { $sort: count: -1, _id: 1 }
            #     { $limit: 42 }
            #     { $project: _id: 0, name: '$_id', count: 1 }
            #     ]

        # else
        # unless query and query.length > 2
        # if picked_tags.length > 0 then match.tags = $all: picked_tags
        # # match.tags = $all: picked_tags
        # # console.log 'match for tags', match
        # tag_cloud = Docs.aggregate [
        #     { $match: match }
        #     { $project: "tags": 1 }
        #     { $unwind: "$tags" }
        #     { $group: _id: "$tags", count: $sum: 1 }
        #     { $match: _id: $nin: picked_tags }
        #     # { $match: _id: {$regex:"#{current_query}", $options: 'i'} }
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


        tag_cloud = Docs.aggregate [
            { $match: match }
            { $project: "tags": 1 }
            { $unwind: "$tags" }
            { $group: _id: "$tags", count: $sum: 1 }
            { $sort: count: -1, _id: 1 }
            { $limit: 20 }
            { $project: _id: 0, title: '$_id', count: 1 }
        ], {
            allowDiskUse: true
        }

        tag_cloud.forEach (tag, i) =>
            # console.log 'tag result ', tag
            self.added 'tags', Random.id(),
                title: tag.title
                count: tag.count
                # category:key
                # index: i


        self.ready()



Router.route '/ingredient/:doc_id', (->
    @render 'ingredient_view'
    ), name:'ingredient_view'
Router.route '/ingredient/:doc_id/edit', (->
    @render 'ingredient_edit'
    ), name:'ingredient_edit'


if Meteor.isClient
    Template.ingredient_view.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id, ->
        @autorun => Meteor.subscribe 'products_from_ingredient_id', Router.current().params.doc_id, ->
    Template.ingredient_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id, ->

    Template.ingredient_orders.onCreated ->
        @autorun => Meteor.subscribe 'ingredient_orders', Router.current().params.doc_id, ->

    Template.purchase_ingredient_button.helpers
        has_purchased: ->
            Docs.findOne 
                model:'order'
                ingredient_id:Router.current().params.doc_id
                _author_id:Meteor.userId()
    Template.purchase_ingredient_button.events 
        'click .purchase_ingredient': ->
            new_id = 
                Docs.insert 
                    model:'order'
                    order_type:'ingredient'
                    ingredient_id:Router.current().params.doc_id 
            # Router.go "/order/#{new_id}/edit"

    Template.ingredient_orders.helpers
        ingredient_order_docs: ->
            Docs.find 
                model:'order'
                ingredient_id:Router.current().params.doc_id

    Template.ingredient_edit.events 
        'keyup body': (e,t)->
            if e.ctrlKey or e.metaKey
                switch String.fromCharCode(e.which).toLowerCase()
                    when 's'
                        e.preventDefault()
                        alert('ctrl-s')
                        break
                    when 'f'
                        e.preventDefault()
                        alert('ctrl-f')
                        break
                    when 'g'
                        e.preventDefault()
                        alert('ctrl-g')
                        break




if Meteor.isServer
    Meteor.publish 'ingredient_orders', (ingredient_id)->
        Docs.find({
            model:'order'
            ingredient_id: ingredient_id
        }, limit:10)

    Meteor.publish 'products_from_ingredient_id', (ingredient_id)->
        Docs.find({
            model:'product'
            ingredient_ids:$in:[ingredient_id]
        }, limit:10)


    Meteor.methods
        calc_ingredient_stats: ->
            ingredient_stat_doc = Docs.findOne(model:'ingredient_stats')
            unless ingredient_stat_doc
                new_id = Docs.insert
                    model:'ingredient_stats'
                ingredient_stat_doc = Docs.findOne(model:'ingredient_stats')
            console.log ingredient_stat_doc
            total_count = Docs.find(model:'ingredient').count()
            complete_count = Docs.find(model:'ingredient', complete:true).count()
            incomplete_count = Docs.find(model:'ingredient', complete:$ne:true).count()
            Docs.update ingredient_stat_doc._id,
                $set:
                    total_count:total_count
                    complete_count:complete_count
                    incomplete_count:incomplete_count