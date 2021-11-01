Meteor.methods
    log_view: (doc_id)->
        Docs.update doc_id,
            $inc:views:1

    log_homepage_view: ->
        stats_doc = 
            Docs.findOne
                model:'stats'
        if stats_doc
            console.log stats_doc
            Docs.remove stats_doc._id
            # Docs.update stats_doc._id,
            #     $inc:homepage_views:1
        else 
            Docs.insert 
                model:'stats'
                app:'nf'
                homepage_views:1

    add_user: (username)->
        options = {}
        options.username = username

        res= Accounts.createUser options
        if res
            return res
        else
            Throw.new Meteor.Error 'err creating user'

    parse_keys: ->
        cursor = Docs.find
            model:'key'
        for key in cursor.fetch()
            # new_building_number = parseInt key.building_number
            new_unit_number = parseInt key.unit_number
            Docs.update key._id,
                $set:
                    unit_number:new_unit_number


    calc_product_data: (product_id)->
        product = Docs.findOne product_id
        # console.log product
        mishi_order_count =
            Docs.find(
                model:'mishi_order'
                product_id:product_id
            ).count()
        # console.log 'order count', mishi_order_count
        # servings_left = product.servings_amount-order_count
        # console.log 'servings left', servings_left
        woo_order_count = 
            Docs.find(
                model:'woo_order'
                product_id:product_id
            ).count()
            
        # product_product =
        #     Docs.findOne product.product_id
        # console.log 'product_product', product_product
        # if product_product.ingredient_ids
        #     product_ingredients =
        #         Docs.find(
        #             model:'ingredient'
        #             _id: $in:product_product.ingredient_ids
        #         ).fetch()
        #
        #     ingredient_titles = []
        #     for ingredient in product_ingredients
        #         console.log ingredient.title
        #         ingredient_titles.push ingredient.title
        #     Docs.update product_id,
        #         $set:
        #             ingredient_titles:ingredient_titles
        # unless product.query_params
        if product.product_link
            qp = product.product_link.split('/')[5]
            split_qp = qp.split('&')
            console.log 'split', split_qp
            console.log 'split', split_qp
            for param in split_qp
                attribute = param.split('=')
                
            Docs.update product_id, 
                $set:query_params:qp

        Docs.update product_id,
            $set:
                mishi_order_count:mishi_order_count
                woo_order_count:woo_order_count
                # servings_left:servings_left



    lookup_user: (username_query, role_filter)->
        if role_filter
            Meteor.users.find({
                username: {$regex:"#{username_query}", $options: 'i'}
                roles:$in:[role_filter]
                },{limit:10}).fetch()
        else
            Meteor.users.find({
                username: {$regex:"#{username_query}", $options: 'i'}
                },{limit:10}).fetch()


    lookup_doc: (guest_name, model_filter)->
        Docs.find({
            model:model_filter
            guest_name: {$regex:"#{guest_name}", $options: 'i'}
            },{limit:10}).fetch()


    # lookup_username: (username_query)->
    #     found_users =
    #         Docs.find({
    #             model:'person'
    #             username: {$regex:"#{username_query}", $options: 'i'}
    #             }).fetch()
    #     found_users

    # lookup_first_name: (first_name)->
    #     found_people =
    #         Docs.find({
    #             model:'person'
    #             first_name: {$regex:"#{first_name}", $options: 'i'}
    #             }).fetch()
    #     found_people
    #
    # lookup_last_name: (last_name)->
    #     found_people =
    #         Docs.find({
    #             model:'person'
    #             last_name: {$regex:"#{last_name}", $options: 'i'}
    #             }).fetch()
    #     found_people



    global_remove: (keyname)->
        result = Docs.update({"#{keyname}":$exists:true}, {
            $unset:
                "#{keyname}": 1
                "_#{keyname}": 1
            $pull:_keys:keyname
            }, {multi:true})


    count_key: (key)->
        count = Docs.find({"#{key}":$exists:true}).count()




    slugify: (doc_id)->
        doc = Docs.findOne doc_id
        slug = doc.title.toString().toLowerCase().replace(/\s+/g, '_').replace(/[^\w\-]+/g, '').replace(/\-\-+/g, '_').replace(/^-+/, '').replace(/-+$/,'')
        return slug
        # # Docs.update { _id:doc_id, fields:field_object },
        # Docs.update { _id:doc_id, fields:field_object },
        #     { $set: "fields.$.slug": slug }


    rename: (old, newk)->
        old_count = Docs.find({"#{old}":$exists:true}).count()
        new_count = Docs.find({"#{newk}":$exists:true}).count()
        console.log 'old count', old_count
        console.log 'new count', new_count
        result = Docs.update({"#{old}":$exists:true}, {$rename:"#{old}":"#{newk}"}, {multi:true})
        result2 = Docs.update({"#{old}":$exists:true}, {$rename:"_#{old}":"_#{newk}"}, {multi:true})

        # > Docs.update({doc_sentiment_score:{$exists:true}},{$rename:{doc_sentiment_score:"sentiment_score"}},{multi:true})
        cursor = Docs.find({newk:$exists:true}, { fields:_id:1 })

        for doc in cursor.fetch()
            Meteor.call 'key', doc._id
# {
# I20210606-18:09:20.217(0)?   _id: 'ep8vJCZWFvNhKPGBL',
# I20210606-18:09:20.218(0)?   model: 'stats',
# I20210606-18:09:20.218(0)?   home_views: 596,
# I20210606-18:09:20.218(0)?   _timestamp: 1611288685997,
# I20210606-18:09:20.219(0)?   _timestamp_long: 'Friday, January 22nd 2021, 4:11:25 am',
# I20210606-18:09:20.219(0)?   _timestamp_tags: [ 'am', 'friday', 'january', '22nd', '2021' ],
# I20210606-18:09:20.219(0)?   homepage_views: 7
# I20210606-18:09:20.220(0)? }                
