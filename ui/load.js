window.addEventListener("message", function (event) {
    const data = event.data;
    if (data.action === "updatePlayer") {
        const player = data.player
        const name = player.name
        const kills = player.kills
        const deaths = player.deaths
        const trophaen = player.trophaen
        const job = player.job
        const permID = player.permID
        const avatar = player.avatar
        const banner = player.banner
        const group = player.group
        const kd = Number(kills) / Number(deaths)
        const zitat = player.zitat
        $("#banner-dui").attr('src', banner)
        $("#avatar-dui").attr('src', avatar)
        $("#name-dui").text(name + " [" + permID + "]")
        $("#group-dui").text(group)
        $("#permid-dui").text("Platz: #" + player.place)
        $("#job-dui").text(job)
        $("#kills-dui").text(kills)
        $("#deaths-dui").text(deaths)
        $("#trophaen-dui").text(trophaen)
        $("#zitat-dui").text("„" + zitat + "”")
        if (kd) {
            $("#kd-dui").text(kd.toFixed(2))
        }else {
            $("#kd-dui").text("0.00")
        }
    }
    if (data.action === "updateTeamler") {
        const player = data.player
        const name = player.name
        const kills = player.kills
        const deaths = player.deaths
        const trophaen = player.trophaen
        const job = player.job
        const permID = player.permID
        const avatar = player.avatar
        const banner = player.banner
        const group = player.group
        const kd = Number(kills) / Number(deaths)
        const zitat = player.zitat
        $("#banner-dui").attr('src', banner)
        $("#avatar-dui").attr('src', avatar)
        $("#name-dui").text(name + " [" + permID + "]")
        $("#group-dui").text(group)
        $("#permid-dui").text(player.place)
        $("#job-dui").text(job)
        $("#kills-dui").text(kills)
        $("#deaths-dui").text(deaths)
        $("#trophaen-dui").text(trophaen)
        $("#zitat-dui").text("„" + zitat + "”")
        $("#kd-dui").text("∞")
    }
});
