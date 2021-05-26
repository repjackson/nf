if Meteor.isClient
    Template.nav.onCreated ->
        @autorun => Meteor.subscribe 'me'
        # @autorun => Meteor.subscribe 'all_users'
        @autorun => Meteor.subscribe 'my_unread_messages'
        @autorun => Meteor.subscribe 'global_stats'
    
    Template.nav.onRendered ->
        Meteor.setTimeout ->
            $('.menu .item')
                .popup()
            $('.ui.left.sidebar')
                .sidebar({
                    context: $('.bottom.segment')
                    transition:'push'
                    exclusive:true
                    duration:200
                    scrollLock:false
                })
                .sidebar('attach events', '.toggle_sidebar')
        , 1000
        Meteor.setTimeout ->
            $('.ui.right.sidebar')
                .sidebar({
                    context: $('.bottom.segment')
                    transition:'push'
                    exclusive:true
                    duration:200
                    scrollLock:false
                })
                .sidebar('attach events', '.toggle_rightbar')
        , 1000
    
    Template.right_sidebar.events
        'click .logout': ->
            Session.set 'logging_out', true
            Meteor.logout ->
                Session.set 'logging_out', false
                Router.go '/login'
                
        'click .toggle_nightmode': ->
            if Meteor.user().invert_class is 'invert'
                Meteor.users.update Meteor.userId(),
                    $set:invert_class:''
            else
                Meteor.users.update Meteor.userId(),
                    $set:invert_class:'invert'
                
    
    Template.nav.events
        'click .add_post': ->
            new_id = 
                Docs.insert 
                    model:'post'
            Router.go "/p/#{new_id}/edit"
    
        'click .alerts': ->
            Session.set('viewing_alerts', !Session.get('viewing_alerts'))
            
        'click .toggle_admin': ->
            if 'admin' in Meteor.user().roles
                Meteor.users.update Meteor.userId(),
                    $pull:'roles':'admin'
            else
                Meteor.users.update Meteor.userId(),
                    $addToSet:'roles':'admin'
        'click .toggle_dev': ->
            if 'dev' in Meteor.user().roles
                Meteor.users.update Meteor.userId(),
                    $pull:'roles':'dev'
            else
                Meteor.users.update Meteor.userId(),
                    $addToSet:'roles':'dev'
        'click .view_profile': ->
            Meteor.call 'calc_user_points', Meteor.userId(), ->
            
        'click .clear_tags': -> picked_tags.clear()
    
    Template.topbar.onCreated ->
        @autorun => Meteor.subscribe 'my_received_messages'
        @autorun => Meteor.subscribe 'my_sent_messages'
    
    Template.nav.helpers
        alert_toggle_class: ->
            if Session.get('viewing_alerts') then 'active' else ''
        unread_count: ->
            Docs.find( 
                model:'message'
                recipient_id:Meteor.userId()
                read_ids:$nin:[Meteor.userId()]
            ).count()
    Template.topbar.helpers
        recent_alerts: ->
            Docs.find 
                model:'message'
                recipient_id:Meteor.userId()
                read_ids:$nin:[Meteor.userId()]
            , sort:_timestamp:-1
            
    Template.recent_alert.events
        'click .mark_read': (e,t)->
            # console.log @
            # console.log $(e.currentTarget).closest('.alert')
            # $(e.currentTarget).closest('.alert').transition('slide left')
            Meteor.call 'mark_read', @_id, ->
                
            # Meteor.setTimeout ->
            # , 500
         
         
            
    Template.topbar.events
        'click .close_topbar': ->
            Session.set('viewing_alerts', false)
    
            
            
    # Template.left_sidebar.events
    #     # 'click .toggle_sidebar': ->
    #     #     $('.ui.sidebar')
    #     #         .sidebar('setting', 'transition', 'push')
    #     #         .sidebar('toggle')
    #     'click .toggle_admin': ->
    #         if 'admin' in Meteor.user().roles
    #             Meteor.users.update Meteor.userId(),
    #                 $pull:'roles':'admin'
    #         else
    #             Meteor.users.update Meteor.userId(),
    #                 $addToSet:'roles':'admin'
    #     'click .toggle_dev': ->
    #         if 'dev' in Meteor.user().roles
    #             Meteor.users.update Meteor.userId(),
    #                 $pull:'roles':'dev'
    #         else
    #             Meteor.users.update Meteor.userId(),
    #                 $addToSet:'roles':'dev'
                    
                
    #     'click .add_gift': ->
    #         # user = Meteor.users.findOne(username:@username)
    #         new_gift_id =
    #             Docs.insert
    #                 model:'gift'
    #                 recipient_id: @_id
    #         Router.go "/debit/#{new_gift_id}/edit"
    
    #     'click .add_request': ->
    #         # user = Meteor.users.findOne(username:@username)
    #         new_id =
    #             Docs.insert
    #                 model:'request'
    #                 recipient_id: @_id
    #         Router.go "/request/#{new_id}/edit"    
    Template.nav.events
        # 'mouseenter .item': (e,t)->
        #     $(e.currentTarget).closest('.item').transition('pulse')
        # 'click .menu_dropdown': ->
            # $('.menu_dropdown').dropdown(
                # on:'hover'
            # )

        'click #logout': ->
            Session.set 'logging_out', true
            Meteor.logout ->
                Session.set 'logging_out', false
                Router.go '/'


    Template.nav.helpers
        unread_count: ->
            unread_count = Docs.find({
                model:'message'
                to_username:Meteor.user().username
                read_by_ids:$nin:[Meteor.userId()]
            }).count()

        cart_amount: ->
            cart_amount = Docs.find({
                model:'cart_item'
                _author_id:Meteor.userId()
            }).count()

