if Meteor.isClient
    Router.route '/shop', (->
        @layout 'layout'
        @render 'shop'
        ), name:'shop'


    Template.shop.onCreated ->
        Session.setDefault 'view_mode', 'list'
        Session.setDefault 'product_sort_key', 'datetime_available'
        Session.setDefault 'product_sort_label', 'available'
        Session.setDefault 'product_limit', 42
        Session.setDefault 'view_open', true

    Template.shop.onCreated ->
        @autorun => @subscribe 'product_facets',
            picked_ingredients.array()
            picked_sections.array()
            Session.get('view_vegan')
            Session.get('view_gf')
            
            Session.get('product_query')
            Session.get('product_limit')
            Session.get('product_sort_key')
            Session.get('product_sort_direction')

        @autorun => @subscribe 'product_results',
            picked_ingredients.array()
            picked_sections.array()
            Session.get('product_query')
            Session.get('view_vegan')
            Session.get('view_gf')
            
            Session.get('product_limit')
            Session.get('product_sort_key')
            Session.get('product_sort_direction')
            
        @autorun => @subscribe 'product_count',
            picked_ingredients.array()
            picked_sections.array()
            Session.get('product_query')
            Session.get('view_vegan')
            Session.get('view_gf')
            
            Session.get('product_limit')
            Session.get('product_sort_key')
            Session.get('product_sort_direction')
            


    Template.shop.events
        'click .add_product': ->
            new_id =
                Docs.insert
                    model:'product'
            Router.go("/product/#{new_id}/edit")


        'click .toggle_vegan': -> Session.set('view_vegan', !Session.get('view_vegan'))
        'click .toggle_gf': -> Session.set('view_gf', !Session.get('view_gf'))
        'click .toggle_pickup': -> Session.set('view_pickup', !Session.get('view_pickup'))
        'click .toggle_open': -> Session.set('view_open', !Session.get('view_open'))

        'click .pick_section': -> picked_sections.push @title
        'click .unpick_section': -> picked_sections.remove @valueOf()
        'click .pick_ingredient': -> picked_ingredients.push @title
        'click .unpick_ingredient': -> picked_ingredients.remove @valueOf()
            # console.log picked_ingredients.array()
            # if picked_ingredients.array().length is 1
                # Meteor.call 'call_wiki', search, ->

            # if picked_ingredients.array().length > 0
                # Meteor.call 'search_reddit', picked_ingredients.array(), ->

        'click .clear_picked_ingredients': ->
            Session.set('product_query',null)
            picked_ingredients.clear()

        'click .clear_product_query': ->
            Session.set('product_query', null)

        'keyup #product_search': _.throttle((e,t)->
            query = $('#product_search').val()
            Session.set('product_query', query)
            # console.log Session.get('product_query')
            if e.key == "Escape"
                Session.set('product_query', null)
                
            if e.which is 13
                search = $('#product_search').val().trim().toLowerCase()
                if search.length > 0
                    picked_tags.push search
                    console.log 'search', search
                    # Meteor.call 'log_term', search, ->
                    $('#product_search').val('')
                    Session.set('product_query', null)
                    # # $('#search').val('').blur()
                    # # $( "p" ).blur();
                    # Meteor.setTimeout ->
                    #     Session.set('dummy', !Session.get('dummy'))
                    # , 10000
        , 1000)

        'click .calc_product_count': ->
            Meteor.call 'calc_product_count', ->

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

        'click .reconnect': ->
            Meteor.reconnect()


        'click .set_sort_direction': ->
            if Session.get('product_sort_direction') is -1
                Session.set('product_sort_direction', 1)
            else
                Session.set('product_sort_direction', -1)


    Template.shop.helpers
        quickbuying_product: ->
            Docs.findOne Session.get('quickbuying_id')

        sorting_up: ->
            parseInt(Session.get('product_sort_direction')) is 1

        toggle_gf_class: -> if Session.get('view_gf') then 'blue' else ''
        toggle_vegan_class: -> if Session.get('view_vegan') then 'blue' else ''
        toggle_open_class: -> if Session.get('view_open') then 'blue' else ''
        # connection: ->
        #     console.log Meteor.status()
        #     Meteor.status()
        # connected: ->
        #     Meteor.status().connected
                    
        product_count: -> Counts.get('product_counter')
     
        tags: ->
            # if Session.get('product_query') and Session.get('product_query').length > 1
            #     Terms.find({}, sort:count:-1)
            # else
            product_count = Docs.find().count()
            # console.log 'product count', product_count
            if product_count < 3
                Results.find({model:'tag', count: $lt: product_count})
            else
                Results.find({model:'tag'})

        ingredients: ->
            # if Session.get('product_query') and Session.get('product_query').length > 1
            #     Terms.find({}, sort:count:-1)
            # else
            product_count = Docs.find(model:'product').count()
            # console.log 'product count', product_count
            if product_count < 3
                Results.find({model:'ingredient', count: $lt: product_count})
            else
                Results.find({model:'ingredient'})

        result_class: ->
            if Template.instance().subscriptionsReady()
                ''
            else
                'disabled'

        picked_ingredients: -> picked_ingredients.array()
        picked_sections: -> picked_sections.array()
        picked_ingredients_plural: -> picked_ingredients.array().length > 1
        searching: -> Session.get('searching')

        product_query: -> Session.get('product_query')

        one_post: ->
            Docs.find(model:'product').count() is 1
        two_posts: ->
            Docs.find(model:'product').count() is 2
        three_posts: ->
            Docs.find(model:'product').count() is 3
        product_docs: ->
            # if picked_ingredients.array().length > 0
            Docs.find {
                model:'product'
            },
                sort: "#{Session.get('product_sort_key')}":parseInt(Session.get('product_sort_direction'))
                limit:Session.get('product_limit')

        subs_ready: ->
            Template.instance().subscriptionsReady()
        users: ->
            # if picked_tags.array().length > 0
            Meteor.users.find {
            },
                sort: count:-1
                # limit:1


        sections: ->
            # if picked_tags.array().length > 0
            Results.find {
                model:'section'
            },
                sort: count:-1
                # limit:1

        product_limit: -> Session.get('product_limit')

        current_product_sort_label: -> Session.get('product_sort_label')


    Template.set_product_limit.events
        'click .set_limit': ->
            console.log @
            Session.set('product_limit', @amount)

    Template.set_product_sort_key.events
        'click .set_sort': ->
            console.log @
            Session.set('product_sort_key', @key)
            Session.set('product_sort_label', @label)
            Session.set('product_sort_icon', @icon)



if Meteor.isServer
    Meteor.publish 'product_results', (
        picked_ingredients
        picked_sections
        product_query
        view_vegan
        view_gf
        
        doc_limit
        doc_sort_key
        doc_sort_direction
        )->
        # console.log picked_ingredients
        if doc_limit
            limit = doc_limit
        else
            limit = 42
        if doc_sort_key
            sort_key = doc_sort_key
        if doc_sort_direction
            sort_direction = parseInt(doc_sort_direction)
        self = @
        match = {model:'product', app:'nf'}
        if picked_ingredients.length > 0
            match.ingredients = $all: picked_ingredients
            # sort = 'price_per_serving'
        if picked_sections.length > 0
            match.menu_section = $all: picked_sections
            # sort = 'price_per_serving'
        # else
            # match.tags = $nin: ['wikipedia']
        sort = '_timestamp'
            # match.source = $ne:'wikipedia'
        if view_vegan
            match.vegan = true
        if view_gf
            match.gluten_free = true
        if product_query and product_query.length > 1
            console.log 'searching product_query', product_query
            match.title = {$regex:"#{product_query}", $options: 'i'}
            # match.tags_string = {$regex:"#{query}", $options: 'i'}

        # match.tags = $all: picked_ingredients
        # if filter then match.model = filter
        # keys = _.keys(prematch)
        # for key in keys
        #     key_array = prematch["#{key}"]
        #     if key_array and key_array.length > 0
        #         match["#{key}"] = $all: key_array
            # console.log 'current facet filter array', current_facet_filter_array

        console.log 'product match', match
        console.log 'sort key', sort_key
        console.log 'sort direction', sort_direction
        Docs.find match,
            sort:"#{sort_key}":sort_direction
            # sort:_timestamp:-1
            limit: limit
            fields:
                title:1
                image_id:1
                ingredients:1
                model:1
                price_usd:1
                vegan:1
                local:1
                gluten_free:1
            
    Meteor.publish 'product_count', (
        picked_ingredients
        picked_sections
        product_query
        view_vegan
        view_gf
        )->
        # @unblock()
    
        # console.log picked_ingredients
        self = @
        match = {model:'product', app:'nf'}
        if picked_ingredients.length > 0
            match.ingredients = $all: picked_ingredients
            # sort = 'price_per_serving'
        if picked_sections.length > 0
            match.menu_section = $all: picked_sections
            # sort = 'price_per_serving'
        # else
            # match.tags = $nin: ['wikipedia']
        sort = '_timestamp'
            # match.source = $ne:'wikipedia'
        if view_vegan
            match.vegan = true
        if view_gf
            match.gluten_free = true
        if product_query and product_query.length > 1
            console.log 'searching product_query', product_query
            match.title = {$regex:"#{product_query}", $options: 'i'}
        Counts.publish this, 'product_counter', Docs.find(match)
        return undefined

    Meteor.publish 'product_facets', (
        picked_ingredients
        picked_sections
        product_query
        view_vegan
        view_gf
        doc_limit
        doc_sort_key
        doc_sort_direction
        view_delivery
        view_pickup
        view_open
        )->
        # console.log 'dummy', dummy
        # console.log 'query', query
        console.log 'picked ingredients', picked_ingredients

        self = @
        match = {app:'nf'}
        match.model = 'product'
        if view_vegan
            match.vegan = true
        if view_gf
            match.gluten_free = true
        # if view_local
        #     match.local = true
        if picked_ingredients.length > 0 then match.ingredients = $all: picked_ingredients
        if picked_sections.length > 0 then match.menu_section = $all: picked_sections
            # match.$regex:"#{product_query}", $options: 'i'}
        if product_query and product_query.length > 1
            console.log 'searching product_query', product_query
            match.title = {$regex:"#{product_query}", $options: 'i'}
            # match.tags_string = {$regex:"#{query}", $options: 'i'}
        #
        #     Terms.find {
        #         title: {$regex:"#{query}", $options: 'i'}
        #     },
        #         sort:
        #             count: -1
        #         limit: 42
            # tag_cloud = Docs.aggregate [
            #     { $match: match }
            #     { $project: "tags": 1 }
            #     { $unwind: "$tags" }
            #     { $group: _id: "$tags", count: $sum: 1 }
            #     { $match: _id: $nin: picked_ingredients }
            #     { $match: _id: {$regex:"#{query}", $options: 'i'} }
            #     { $sort: count: -1, _id: 1 }
            #     { $limit: 42 }
            #     { $project: _id: 0, name: '$_id', count: 1 }
            #     ]

        # else
        # unless query and query.length > 2
        # if picked_ingredients.length > 0 then match.tags = $all: picked_ingredients
        # # match.tags = $all: picked_ingredients
        # # console.log 'match for tags', match
        section_cloud = Docs.aggregate [
            { $match: match }
            { $project: "menu_section": 1 }
            { $group: _id: "$menu_section", count: $sum: 1 }
            { $match: _id: $nin: picked_sections }
            # { $match: _id: {$regex:"#{product_query}", $options: 'i'} }
            { $sort: count: -1, _id: 1 }
            { $limit: 20 }
            { $project: _id: 0, name: '$_id', count: 1 }
        ], {
            allowDiskUse: true
        }
        
        section_cloud.forEach (section, i) =>
            # console.log 'queried section ', section
            # console.log 'key', key
            self.added 'results', Random.id(),
                title: section.name
                count: section.count
                model:'section'
                # category:key
                # index: i


        ingredient_cloud = Docs.aggregate [
            { $match: match }
            { $project: "ingredients": 1 }
            { $unwind: "$ingredients" }
            { $match: _id: $nin: picked_ingredients }
            { $group: _id: "$ingredients", count: $sum: 1 }
            { $sort: count: -1, _id: 1 }
            { $limit: 20 }
            { $project: _id: 0, title: '$_id', count: 1 }
        ], {
            allowDiskUse: true
        }

        ingredient_cloud.forEach (ingredient, i) =>
            # console.log 'ingredient result ', ingredient
            self.added 'results', Random.id(),
                title: ingredient.title
                count: ingredient.count
                model:'ingredient'
                # category:key
                # index: i


        self.ready()





if Meteor.isClient
    Template.product_card.onCreated ->
        # @autorun => Meteor.subscribe 'model_docs', 'food'
    Template.product_card.events
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
            # $(e.currentTarget).closest('.card').transition('zoom',420)
            # $('.global_container').transition('scale', 500)
            Router.go("/food/#{@_id}")
            # Meteor.setTimeout =>
            # , 100

        # 'click .view_card': ->
        #     $('.container_')

    Template.product_card.helpers
        product_card_class: ->
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
