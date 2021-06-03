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
        # @autorun => Meteor.subscribe 'model_docs', 'product'
        @autorun => Meteor.subscribe 'my_cart'
        @autorun => Meteor.subscribe 'my_cart_products'
        if Meteor.user()
            @autorun => Meteor.subscribe 'username_model_docs', 'address', Meteor.user().username, ->
    Template.checkout.onCreated ->
        # if Meteor.user()
        @autorun => Meteor.subscribe 'model_docs', 'address', ->
        @autorun => Meteor.subscribe 'my_cart_products'
        # @autorun => Meteor.subscribe 'model_docs', 'product'
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
    Template.checkout.events
        'click .checkout_cart': ->
            cart_order = 
                Docs.findOne    
                    model:'order'
                    complete:false
            if cart_order
                subtotal = 0
                for cart_item in Docs.find(model:'cart_item',_author_id:Meteor.userId()).fetch()
                    product = Docs.findOne(cart_item.product_id)
                    # console.log product
                    if product
                        if product.price_usd
                            subtotal += product.price_usd*cart_item.amount
                    # if product.price_usd
                    #     console.log product.price_usd
                        # console.log 'product', product
                # console.log subtotal
                subtotal.toFixed(2)
                Docs.update cart_order._id,
                    $set:subtotal:subtotal.toFixed(2)
                Swal.fire({
                    title: "confirm purchase of #{subtotal.toFixed(2)}"
                    # text: "#{@subtotal} credits"
                    icon: 'question'
                    showCancelButton: true,
                    confirmButtonText: 'confirm'
                    cancelButtonText: 'cancel'
                }).then((result) =>
                    Docs.update @_id,
                        $set:
                            complete:true
                            complete_timestamp:Date.now()
                    Meteor.users.update Meteor.userId(),
                        $inc:credit:-subtotal.toFixed(2)
                    Router.go("/order/#{@_id}")
                )
            
    
    Template.checkout.helpers
        cart_order: ->
            Docs.findOne    
                model:'order'
                complete:false
            
            
        cart_items: ->
            Docs.find
                model:'cart_item'
                # ingredient_ids: $in: [@_id]
    Template.topup_button.events
        'click .initiate_topup':->
            Swal.fire({
                title: "topup for #{@amount}"
                # text: "#{@subtotal} credits"
                icon: 'question'
                showCancelButton: true,
                confirmButtonText: 'confirm'
                cancelButtonText: 'cancel'
            }).then((result) =>
                Docs.insert
                    model:'balance_topup'
                    amount:parseInt(@amount)
                Meteor.users.update Meteor.userId(),
                    $inc:credit:parseInt(@amount)
            )


if Meteor.isServer
    Meteor.publish 'my_cart', ->
        Docs.find
            model:'cart_item'
            _author_id: Meteor.userId()
            app:'nf'
            complete:false
            
            
    Meteor.publish 'my_cart_order', ->
        Docs.find
            model:'order'
            _author_id: Meteor.userId()
            complete:false
          
    Meteor.publish 'product_from_cart_item', (cart_item_id)->
        cart_item = Docs.findOne cart_item_id
        Docs.find cart_item.product_id
            
            
    Meteor.publish 'my_cart_products', ->
        # cart_items = 
        cart_items = 
            Docs.find({
                model:'cart_item'
                _author_id: Meteor.userId()
                complete:false
            }, {fields:{product_id:1}}).fetch()
        # console.log 'product_ids', _.values(product_ids)
        product_ids = []
        for cart_item in cart_items
            product_ids.push cart_item.product_id
        console.log product_ids
        Docs.find({
            model:'product'
            _id:$in:product_ids
        }, {fields:
                title:1
                model:1
                image_id:1
                price_usd:1
        })
            