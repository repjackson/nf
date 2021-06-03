if Meteor.isClient
    Router.route '/cart', (->
        @layout 'layout'
        @render 'cart'
        ), name:'cart'
    Router.route '/checkout', (->
        @layout 'layout'
        @render 'checkout'
        ), name:'checkout'

    Template.cart.onCreated ->
        # @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'model_docs', 'product'
        @autorun => Meteor.subscribe 'my_cart'
    Template.checkout.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'product'
        @autorun => Meteor.subscribe 'my_cart'
        @autorun => Meteor.subscribe 'my_cart_order'

    Template.cart.events
        'click .checkout_cart':->
            
            # Docs.update @_id, 
            #     status:'checking out'
            cart_order = 
                Docs.findOne
                    model:'order'
                    complete:false
            unless cart_order
                Docs.insert
                    model:'order'
                    complete:false
                    status:'checking_out'
                    
            Router.go '/checkout'
                
        'click .remove_item': (e,t)->
            product = 
                Docs.findOne
                    model:'product'
                    
                    _id:@product_id
            console.log product
            
            Swal.fire({
                title: "remove #{product.title}?"
                # text: "cannot be undone"
                icon: 'question'
                confirmButtonText: 'delete'
                confirmButtonColor: 'red'
                showCancelButton: true
                cancelButtonText: 'cancel'
                reverseButtons: true
            }).then((result)=>
                if result.value
                    $(e.currentTarget).closest('.item').transition('slide left', 1000)
                    Meteor.setTimeout =>
                        Docs.remove @_id
                    , 1000
                    # Swal.fire(
                    #     position: 'top-end',
                    #     icon: 'success',
                    #     title: 'item removed',
                    #     showConfirmButton: false,
                    #     timer: 1500
                    # )
            )
        'click .increase_amount': (e,t)->
            Docs.update @_id, 
                $inc:amount:1
            $(e.currentTarget).closest('.item').transition('bounce',500)
                
        'click .decrease_amount': (e,t)->
            if @amount and @amount is 1
                $(e.currentTarget).closest('.item').transition('slide left', 1000)
                Meteor.setTimeout =>
                    Docs.remove @_id
                , 1000
            else
                $(e.currentTarget).closest('.item').transition('shake', 500)
                # console.log
                Docs.update @_id, 
                    $inc:amount:-1

    Template.cart.helpers
        cart_items: ->
            Docs.find
                model:'cart_item'
                # ingredient_ids: $in: [@_id]
    Template.checkout.helpers
        cart_order: ->
            Docs.findOne    
                model:'order'
                complete:false
            
            
        cart_items: ->
            Docs.find
                model:'cart_item'
                # ingredient_ids: $in: [@_id]


if Meteor.isServer
    Meteor.publish 'my_cart', ->
        Docs.find
            model:'cart_item'
            _author_id: Meteor.userId()
            app:'nf'
            
            
    Meteor.publish 'my_cart_order', ->
        Docs.find
            model:'order'
            _author_id: Meteor.userId()
            complete:false
            
            
            