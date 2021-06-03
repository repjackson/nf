if Meteor.isClient
    Router.route '/cart', (->
        @layout 'layout'
        @render 'cart'
        ), name:'cart'

    Template.cart.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'model_docs', 'product'
        @autorun => Meteor.subscribe 'my_cart'

    Template.cart.events
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

    Template.cart.helpers
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