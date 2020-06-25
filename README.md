# YouTube ListBlock

#### Portuguese

Black list do YouTube para Pi-Hole, Adguard Home e Adblock-OpenWRT. Esta lista é gerada automaticamente por scripts baseados neste [aqui](https://discourse.pi-hole.net/t/how-do-i-block-ads-on-youtube/253/456).

Para utilizar a lista no seu Pi-Hole ou Adguard Home coloque `https://gitlab.com/marieldejesus12/youtube-listblock/-/raw/master/youtube.txt` como uma Adlist.

Para utilizar a lista no Adblock-OpenWRT baixe o [script](https://gitlab.com/marieldejesus12/youtube-listblock/-/raw/master/openwrt_adblock.sh) em seu OpenWRT e execute `sh openwrt_adblock.sh install`. Tudo será configurado automaticamente.

É possível ajudar na coleta de urls de propagandas de vídeos. Para isso é preciso baixar o script para seu sistema (Pi-Hole, Adguard ou OpenWRT) e instalar o mesmo. O script verificará por depêndencias e instalará automaticamente as mesmas, se moverá para `/usr/bin` e ajustará seu crontrab para execução automática de madrugada. **Os scripts de coleta me enviam as urls coletadas pelo Telegram (tudo de forma anônima) assim que é feito um update na lista para que eu possa atualizar a lista geral hospedada nesse repositório**. Os scripts deixam a lista de urls disponíveis em http://localhost/youtube.txt para que você possa utilizar em seu Pi-Hole/Adguard Home/Adblock-OpenWRT. Quando o Adguard Home estiver sendo executado em sistemas que não o OpenWRT a lista local será gerada em $ADGUARDDIR/youtube.txt.

**Para utilizar o script de coleta execute:**

Baixe o script para [Pi-Hole](https://gitlab.com/marieldejesus12/youtube-listblock/-/raw/master/pihole_collect.sh) em seu sistema e execute `sudo bash pihole_collect.sh install`

Download the script to [Adguard Home](https://gitlab.com/marieldejesus12/youtube-listblock/-/raw/master/adguard_collect.sh) on your system, set the variable `ADGUARDDIR='/opt/AdGuardHome'` on line 39 indicating the Adguard Home folder path and run `sudo bash adguard_collect.sh install` for non-OpenWRT systems and` sh adguard_collect.sh install` for OpenWRT systems

Baixe o script para [OpenWRT](https://gitlab.com/marieldejesus12/youtube-listblock/-/raw/master/openwrt_collect.sh) em seu sistema e execute `sh openwrt_collect.sh install`

Tudo será configurado automaticamente.


#### English (Google Translate)

YouTube black list for Pi-Hole, Adguard Home and Adblock-OpenWRT. This list is automatically generated by scripts based on this [here](https://discourse.pi-hole.net/t/how-do-i-block-ads-on-youtube/253/456).

To use the list on your Pi-Hole or Adguard Home place `https://gitlab.com/marieldejesus12/youtube-listblock/-/raw/master/youtube.txt` as an Adlist.

To use the list in Adblock-OpenWRT download the [script](https://gitlab.com/marieldejesus12/youtube-listblock/-/raw/master/openwrt_adblock.sh) in your OpenWRT and run `sh openwrt_adblock.sh install`. Everything will be set up automatically.

It is possible to assist in the collection of video advertising urls. To do this, you need to download the script to your system (Pi-Hole, Adguard or OpenWRT) and install it. The script will check for dependencies and automatically install them, move to `/usr/bin` and set your crontrab to run automatically at dawn. **The collection scripts send me the urls collected by Telegram (all anonymously) as soon as the list is updated so that I can update the general list hosted in that repository**. The scripts leave the list of urls available at http://localhost/youtube.txt for you to use in your Pi-Hole/Adguard Home/Adblock-OpenWRT. When Adguard Home is running on systems other than OpenWRT the local list will be generated in $ADGUARDDIR/youtube.txt.

Download the script to [Pi-Hole](https://gitlab.com/marieldejesus12/youtube-listblock/-/raw/master/pihole_collect.sh) on your system and run `sudo bash pihole_collect.sh install`

Download the script to [Adguard Home](https://gitlab.com/marieldejesus12/youtube-listblock/-/raw/master/adguard_collect.sh) on your system, set the variable `ADGUARDDIR='/opt/AdGuardHome'` on line 39 starting the Adguard Home folder path and run `sudo bash adguard_collect.sh install` for non-OpenWRT system and` sh adguard_collect.sh install` for OpenWRT systems

Download the script for [OpenWRT](https://gitlab.com/marieldejesus12/youtube-listblock/-/raw/master/openwrt_collect.sh) on your system and run `sh openwrt_collect.sh install`

Everything will be set up automatically.
