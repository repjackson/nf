if Meteor.isClient
    Router.route '/things', (->
        @layout 'layout'
        @render 'things'
        ), name:'things'
    Router.route '/thing/:doc_id/edit', (->
        @layout 'layout'
        @render 'thing_edit'
        ), name:'thing_edit'
    Router.route '/thing/:doc_id', (->
        @layout 'layout'
        @render 'thing_view'
        ), name:'thing_view'
    Router.route '/thing/:doc_id/view', (->
        @layout 'layout'
        @render 'thing_view'
        ), name:'thing_view_long'
    
    Template.registerHelper 'claimer', () ->
        Meteor.users.findOne @claimed_user_id
    Template.registerHelper 'completer', () ->
        Meteor.users.findOne @completed_by_user_id
    
    Template.thing_view.onCreated ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id, ->
    Template.thing_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id, ->
    Template.thing_card.onCreated ->
        @autorun => Meteor.subscribe 'doc_comments', @data._id, ->


    Template.thing_card.events
        'click .view_thing': ->
            Router.go "/thing/#{@_id}"
    Template.thing_item.events
        'click .view_thing': ->
            Router.go "/thing/#{@_id}"

    Template.thing_view.events
        'click .add_thing_recipe': ->
            new_id = 
                Docs.insert 
                    model:'recipe'
                    thing_ids:[@_id]
            Router.go "/recipe/#{new_id}/edit"

    Template.favorite_icon_toggle.helpers
        icon_class: ->
            if @favorite_ids and Meteor.userId() in @favorite_ids
                'red'
            else
                'outline'
    Template.favorite_icon_toggle.events
        'click .toggle_fav': ->
            if @favorite_ids and Meteor.userId() in @favorite_ids
                Docs.update @_id, 
                    $pull:favorite_ids:Meteor.userId()
            else
                $('body').toast(
                    showIcon: 'heart'
                    message: "marked favorite"
                    showProgress: 'bottom'
                    class: 'success'
                    # displayTime: 'auto',
                    position: "bottom right"
                )

                Docs.update @_id, 
                    $addToSet:favorite_ids:Meteor.userId()
    
    
    Template.thing_edit.events
        'click .delete_thing': ->
            Swal.fire({
                title: "delete thing?"
                text: "cannot be undone"
                icon: 'question'
                confirmButtonText: 'delete'
                confirmButtonColor: 'red'
                showCancelButton: true
                cancelButtonText: 'cancel'
                reverseButtons: true
            }).then((result)=>
                if result.value
                    Docs.remove @_id
                    Swal.fire(
                        position: 'top-end',
                        icon: 'success',
                        title: 'thing removed',
                        showConfirmButton: false,
                        timer: 1500
                    )
                    Router.go "/thing"
            )

        'click .publish': ->
            Swal.fire({
                title: "publish thing?"
                text: "point bounty will be held from your account"
                icon: 'question'
                confirmButtonText: 'publish'
                confirmButtonColor: 'green'
                showCancelButton: true
                cancelButtonText: 'cancel'
                reverseButtons: true
            }).then((result)=>
                if result.value
                    Meteor.call 'publish_thing', @_id, =>
                        Swal.fire(
                            position: 'bottom-end',
                            icon: 'success',
                            title: 'thing published',
                            showConfirmButton: false,
                            timer: 1000
                        )
            )

        'click .unpublish': ->
            Swal.fire({
                title: "unpublish thing?"
                text: "point bounty will be returned to your account"
                icon: 'question'
                confirmButtonText: 'unpublish'
                confirmButtonColor: 'orange'
                showCancelButton: true
                cancelButtonText: 'cancel'
                reverseButtons: true
            }).then((result)=>
                if result.value
                    Meteor.call 'unpublish_thing', @_id, =>
                        Swal.fire(
                            position: 'bottom-end',
                            icon: 'success',
                            title: 'thing unpublished',
                            showConfirmButton: false,
                            timer: 1000
                        )
            )
            
            
if Meteor.isClient
    Template.things.onCreated ->
        Session.setDefault 'view_mode', 'list'
        Session.setDefault 'thing_sort_key', 'datetime_available'
        Session.setDefault 'thing_sort_label', 'available'
        Session.setDefault 'thing_limit', 42
        Session.setDefault 'view_open', true

        @autorun => @subscribe 'thing_facets',
            picked_ingredients.array()
            picked_sections.array()
            Session.get('view_vegan')
            Session.get('view_gf')
            
            Session.get('thing_query')
            Session.get('thing_limit')
            Session.get('thing_sort_key')
            Session.get('thing_sort_direction')

        @autorun => @subscribe 'thing_results'
        @autorun => @subscribe 'thing_count',
            picked_ingredients.array()
            picked_sections.array()
            Session.get('thing_query')
            Session.get('view_vegan')
            Session.get('view_gf')
            
            Session.get('thing_limit')
            Session.get('thing_sort_key')
            Session.get('thing_sort_direction')
            


    Template.things.events
        'click .add_thing': ->
            new_id =
                Docs.insert
                    model:'thing'
            Router.go("/thing/#{new_id}/edit")


        'click .toggle_vegan': -> Session.set('view_vegan', !Session.get('view_vegan'))
        'click .toggle_gf': -> Session.set('view_gf', !Session.get('view_gf'))
        'click .toggle_pickup': -> Session.set('view_pickup', !Session.get('view_pickup'))
        'click .toggle_open': -> Session.set('view_open', !Session.get('view_open'))

        'keyup #thing_search': _.throttle((e,t)->
            query = $('#thing_search').val()
            Session.set('thing_query', query)
            # console.log Session.get('thing_query')
            if e.key == "Escape"
                Session.set('thing_query', null)
                
            if e.which is 13
                search = $('#thing_search').val().trim().toLowerCase()
                if search.length > 0
                    picked_tags.push search
                    console.log 'search', search
                    # Meteor.call 'log_term', search, ->
                    $('#thing_search').val('')
                    Session.set('thing_query', null)
                    # # $('#search').val('').blur()
                    # # $( "p" ).blur();
                    # Meteor.setTimeout ->
                    #     Session.set('dummy', !Session.get('dummy'))
                    # , 10000
        , 1000)

        'click .calc_thing_count': ->
            Meteor.call 'calc_thing_count', ->

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
            if Session.get('thing_sort_direction') is -1
                Session.set('thing_sort_direction', 1)
            else
                Session.set('thing_sort_direction', -1)


    Template.things.helpers
        quickbuying_thing: ->
            Docs.findOne Session.get('quickbuying_id')

        sorting_up: ->
            parseInt(Session.get('thing_sort_direction')) is 1

        toggle_gf_class: -> if Session.get('view_gf') then 'blue' else ''
        toggle_vegan_class: -> if Session.get('view_vegan') then 'blue' else ''
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
                    
        thing_count: -> Counts.get('thing_counter')
     
        tags: ->
            # if Session.get('thing_query') and Session.get('thing_query').length > 1
            #     Terms.find({}, sort:count:-1)
            # else
            thing_count = Docs.find().count()
            # console.log 'thing count', thing_count
            if thing_count < 3
                Results.find({model:'tag', count: $lt: thing_count})
            else
                Results.find({model:'tag'})

        ingredients: ->
            # if Session.get('thing_query') and Session.get('thing_query').length > 1
            #     Terms.find({}, sort:count:-1)
            # else
            thing_count = Docs.find(model:'thing').count()
            # console.log 'thing count', thing_count
            if thing_count < 3
                Results.find({model:'ingredient', count: $lt: thing_count})
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

        thing_query: -> Session.get('thing_query')

        one_thing: ->
            Docs.find(model:'thing').count() is 1
        two_things: ->
            Docs.find(model:'thing').count() is 2
        three_things: ->
            Docs.find(model:'thing').count() is 3
        thing_docs: ->
            # if picked_ingredients.array().length > 0
            Docs.find {
                model:'thing'
            },
                sort: "#{Session.get('thing_sort_key')}":parseInt(Session.get('thing_sort_direction'))
                limit:Session.get('thing_limit')

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

        thing_limit: -> Session.get('thing_limit')

        current_thing_sort_label: -> Session.get('thing_sort_label')


    Template.set_thing_limit.events
        'click .set_limit': ->
            console.log @
            Session.set('thing_limit', @amount)

    Template.set_thing_sort_key.events
        'click .set_sort': ->
            console.log @
            Session.set('thing_sort_key', @key)
            Session.set('thing_sort_label', @label)
            Session.set('thing_sort_icon', @icon)



if Meteor.isServer
    Meteor.publish 'thing_results', (
        )->
        # console.log picked_ingredients
        # if doc_limit
        #     limit = doc_limit
        # else
        limit = 42
        # if doc_sort_key
        #     sort_key = doc_sort_key
        # if doc_sort_direction
        #     sort_direction = parseInt(doc_sort_direction)
        self = @
        match = {model:'thing', app:'nf'}
        # if picked_ingredients.length > 0
        #     match.ingredients = $all: picked_ingredients
        #     # sort = 'price_per_serving'
        # if picked_sections.length > 0
        #     match.menu_section = $all: picked_sections
            # sort = 'price_per_serving'
        # else
            # match.tags = $nin: ['wikipedia']
        sort = '_timestamp'
        match.published = true
            # match.source = $ne:'wikipedia'
        # if view_vegan
        #     match.vegan = true
        # if view_gf
        #     match.gluten_free = true
        # if thing_query and thing_query.length > 1
        #     console.log 'searching thing_query', thing_query
        #     match.title = {$regex:"#{thing_query}", $options: 'i'}
        #     # match.tags_string = {$regex:"#{query}", $options: 'i'}

        # match.tags = $all: picked_ingredients
        # if filter then match.model = filter
        # keys = _.keys(prematch)
        # for key in keys
        #     key_array = prematch["#{key}"]
        #     if key_array and key_array.length > 0
        #         match["#{key}"] = $all: key_array
            # console.log 'current facet filter array', current_facet_filter_array

        # console.log 'thing match', match
        # console.log 'sort key', sort_key
        # console.log 'sort direction', sort_direction
        Docs.find match,
            # sort:"#{sort_key}":sort_direction
            # sort:_timestamp:-1
            limit: 42
            
            
    Meteor.publish 'thing_count', (
        picked_ingredients
        picked_sections
        thing_query
        view_vegan
        view_gf
        )->
        # @unblock()
    
        # console.log picked_ingredients
        self = @
        match = {model:'thing', app:'nf'}
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
        if thing_query and thing_query.length > 1
            console.log 'searching thing_query', thing_query
            match.title = {$regex:"#{thing_query}", $options: 'i'}
        Counts.publish this, 'thing_counter', Docs.find(match)
        return undefined

    Meteor.publish 'thing_facets', (
        picked_ingredients
        picked_sections
        thing_query
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
        match.model = 'thing'
        if view_vegan
            match.vegan = true
        if view_gf
            match.gluten_free = true
        if picked_ingredients.length > 0 then match.ingredients = $all: picked_ingredients
        if picked_sections.length > 0 then match.menu_section = $all: picked_sections
            # match.$regex:"#{thing_query}", $options: 'i'}
        if thing_query and thing_query.length > 1
            console.log 'searching thing_query', thing_query
            match.title = {$regex:"#{thing_query}", $options: 'i'}
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
            # { $match: _id: {$regex:"#{thing_query}", $options: 'i'} }
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
    Template.thing_card.onCreated ->
        # @autorun => Meteor.subscribe 'model_docs', 'food'
    Template.thing_card.events
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

    Template.thing_card.helpers
        thing_card_class: ->
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
            