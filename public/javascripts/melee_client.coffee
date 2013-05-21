class MeleeClient
  constructor: (guid, client_guid, mirror) ->
    @guid = guid
    @client_guid = client_guid
    @mirror = mirror
    @has_control = false
    @postTimeout = null

    # create faye_client
    if Faye.Client?
      @faye_client = new Faye.Client('http://faye.rubymelee.com/melee');

      @faye_client.subscribe "/#{guid}/sync", (data) =>
        @sync data.body if data.sender != @client_guid

      @faye_client.subscribe "/#{guid}/update", (data) =>
        @update data

    mirror.on 'change', @do_sync

  do_sync: (mirror, change) =>

    # publish changes to faye
    @faye_client.publish "/#{@guid}/sync",
      body: JSON.stringify(change)
      sender: @client_guid

    clearTimeout(@postTimeout) if @postTimeout?
    @postTimeout = setTimeout @post_content, 2000

  release_control: () ->
    @has_control = false

  update: (data) ->
    msg = JSON.parse data

    # update melee 
    @mirror.off 'change', @do_sync

    # save the cursor position
    pos = @mirror.getCursor()

    @mirror.setValue msg.content
    $('#output pre').html msg.output

    @mirror.setCursor pos
    @mirror.on 'change', @do_sync

  sync: (message) ->
    msg = JSON.parse message

    # update melee 
    @mirror.off 'change', @do_sync
    @mirror.replaceRange msg.text, msg.to, msg.from

    if msg.next?
      @mirror.replaceRange msg.next.text, msg.next.to, msg.next.from

    @mirror.on 'change', @do_sync

  post_content: () =>
    
    melee_url = "/melee/#{@guid}"
    data = 
      content: @mirror.getValue()

    $.post melee_url, data, (return_data, status, jq_xhr) ->
      $('#output pre').html return_data.output

window.MeleeClient = MeleeClient
