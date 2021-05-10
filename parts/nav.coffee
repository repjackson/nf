if Meteor.isClient
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

    Template.nav.onCreated ->
        @autorun -> Meteor.subscribe 'me'
        # @autorun -> Meteor.subscribe 'users'
        # @autorun -> Meteor.subscribe 'users_by_role','staff'
        # @autorun -> Meteor.subscribe 'unread_messages'

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

