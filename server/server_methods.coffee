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


    change_username:  (user_id, new_username) ->
        user = Meteor.users.findOne user_id
        Accounts.setUsername(user._id, new_username)
        return "updated username to #{new_username}."


    add_email: (user_id, new_email) ->
        Accounts.addEmail(user_id, new_email);
        Accounts.sendVerificationEmail(user_id, new_email)
        return "updated email to #{new_email}"

    remove_email: (user_id, email)->
        # user = Meteor.users.findOne username:username
        Accounts.removeEmail user_id, email


    verify_email: (user_id, email)->
        user = Meteor.users.findOne user_id
        console.log 'sending verification', user.username
        Accounts.sendVerificationEmail(user_id, email)

    validate_email: (email) ->
        re = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/
        re.test String(email).toLowerCase()


    notify_message: (message_id)->
        message = Docs.findOne message_id
        if message
            to_user = Meteor.users.findOne message.to_user_id

            message_link = "https://www.goldrun.online/user/#{to_user.username}/messages"

        	Email.send({
                to:["<#{to_user.emails[0].address}>"]
                from:"relay@goldrun.online"
                subject:"gold run message from #{message._author_username}"
                html: "<h3> #{message._author_username} sent you the message:</h3>"+"<h2> #{message.body}.</h2>"+
                    "<br><h4>view your messages here:<a href=#{message_link}>#{message_link}</a>.</h4>"
            })

    order_product: (product_id)->
        product = Docs.findOne product_id
        order_id = Docs.insert
            model:'order'
            product_id: product._id
            status:'pending'
            order_price: product.price_usd
            buyer_id: Meteor.userId()
        Meteor.users.update Meteor.userId(),
            $inc:credit:-product.price_usd
        Meteor.users.update product.cook_user_id,
            $inc:credit:product.price_usd
        Meteor.call 'calc_product_data', product_id, ->
        order_id


    calc_product_data: (product_id)->
        product = Docs.findOne product_id
        console.log product
        order_count =
            Docs.find(
                model:'order'
                product_id:product_id
            ).count()
        console.log 'order count', order_count
        servings_left = product.servings_amount-order_count
        console.log 'servings left', servings_left

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

        Docs.update product_id,
            $set:
                order_count:order_count
                servings_left:servings_left



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


    set_password: (user_id, new_password)->
        Accounts.setPassword(user_id, new_password)



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

    send_enrollment_email: (user_id, email)->
        user = Meteor.users.findOne(user_id)
        console.log 'sending enrollment email to username', user.username
        Accounts.sendEnrollmentEmail(user_id)
# {
# I20210606-18:09:20.217(0)?   _id: 'ep8vJCZWFvNhKPGBL',
# I20210606-18:09:20.218(0)?   model: 'stats',
# I20210606-18:09:20.218(0)?   home_views: 596,
# I20210606-18:09:20.218(0)?   _timestamp: 1611288685997,
# I20210606-18:09:20.219(0)?   _timestamp_long: 'Friday, January 22nd 2021, 4:11:25 am',
# I20210606-18:09:20.219(0)?   _timestamp_tags: [ 'am', 'friday', 'january', '22nd', '2021' ],
# I20210606-18:09:20.219(0)?   homepage_views: 7
# I20210606-18:09:20.220(0)? }                
