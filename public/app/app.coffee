(($) ->
  app = $.sammy( '#todos', ->
    @use 'Template'
    @notFound = (verb, path) ->
      @runRoute "get", "#/404"

    @get "#/404", ->
      @partial "/404.template", {}, (html) ->
        $("#todo-list").html html

    @get "#/list/:id", ->
      list = Lists.get(@params["id"])
      console.log list
      if list
        @partial "/todolist.template",
          list: list
          todos: Todos.filter("listId", list.id)
        , (html) ->
          $("#todo-list").html html
      else
        @notFound()

    
    # events 
    #  (e, data) 
    @bind "run", ->
      context = this
      title = localStorage.getItem("title") or "Todos"
      $("h1").text title
      list = Lists.create(name: "My new list")  if Lists._data.length <= 0
      
      #app.trigger('updateLists');
      $("#new-todo").keydown (e) ->
        if e.keyCode is 13
          todoContent = $(this).val()
          todo = Todos.create(
            name: todoContent
            done: false
            listId: parseInt($("#todo-list").attr("data-id"), 10)
          )
          console.log todo
          context.render "/todo.template", todo, (html) ->
            $("#todo-list").append html

          $(this).val ""

      $(".trashcan").live "click", ->
        $this = $(this)
        app.trigger "delete",
          type: $this.attr("data-type")
          id: $this.attr("data-id")


      
      #new
      $(".check").live "click", ->
        $this = $(this)
        $li = $this.parents("li").toggleClass("done")
        isDone = $li.is(".done")
        app.trigger "mark" + ((if isDone then "Done" else "Undone")),
          id: $li.attr("data-id")

      # store the current value
      # grab the, likely, modified value
      # restore the previous value if text is empty
      # it is the title
      # save it
      $("[contenteditable]").live("focus", ->
        $.data this, "prevValue", $(this).text()
      ).live("blur", ->
        $this = $(this)
        text = $.trim($this.text())
        unless text
          $this.text $.data(this, "prevValue")
        else
          if $this.is("h1")
            localStorage.setItem "title", text
          else
            app.trigger "save",
              type: $this.attr("data-type")
              id: $this.attr("data-id")
              name: text

      ).live "keypress", (event) ->
        
        # save on enter
        if event.which is 13
          @blur()
          false

      unless localStorage.getItem("initialized")
        
        # create first list and todo
        listId = Lists.create(name: "My first list").id
        
        #
        #                Todos.create({
        #                    name: 'My first todo',
        #                    done: false,
        #                    listId: listId
        #                });
        #                
        localStorage.setItem "initialized", "yup"
        @redirect "#/list/" + listId
      else
        lastViewedOrFirstList = localStorage.getItem("lastviewed") or "#/list/" + Lists.first().id
        @redirect lastViewedOrFirstList

    
    #save the route as the lastviewed item
    @bind "route-found", (e, data) ->
      localStorage.setItem "lastviewed", document.location.hash

    @bind "save", (e, data) ->
      model = (if data.type is "todo" then Todos else Lists)
      model.update data.id,
        name: data.name


    
    #marking the selected item as done
    @bind "markDone", (e, data) ->
      Todos.update data.id,
        done: true


    
    #mark the todo with the selected id as not done
    @bind "markUndone", (e, data) ->
      Todos.update data.id,
        done: false


    @bind "delete", (e, data) ->
      
      #if (confirm('Are you sure you want to delete this ' + data.type + '?')) {
      model = (if data.type is "list" then Lists else Todos)
      model.destroy data.id
      if data.type is "list"
        list = Lists.first()
        if list
          @redirect "#/list/" + list.id
        else
          
          # create first list and todo
          listId = Lists.create(name: "Initial list").id
          Todos.create
            name: "A sample todo item"
            done: false
            listId: listId

          @redirect "#/list/" + listId
      else
        
        # delete the todo from the view
        $("li[data-id=" + data.id + "]").remove()

  )
  
  # lists model
  Lists = Object.create(Model)
  Lists.name = "lists-sammyjs"
  Lists.init()
  
  # todos model
  Todos = Object.create(Model)
  Todos.name = "todos-sammyjs"
  Todos.init()
  $ ->
    app.run()

) jQuery      
