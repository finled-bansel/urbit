!:                                                      ::  /van/jael
::                                                      ::  %reference/0
!?  150
::
::
::  %jael: secrets and promises.
::
::  todo:
::
::    - communication with other vanes:
::      - actually use %behn for expiring secrets
::      - report %ames propagation errors to user
::
::    - nice features:
::      - scry namespace
::      - task for converting invites to tickets
::
|=  pit/vase
=,  pki:jael
=,  rights:jael
=,  able:jael
=,  crypto
=,  jael
=,  ethe
=,  constitution:ethe
=,  ethereum
=,  constitution:ethereum
::                                                      ::::
::::                    # models                        ::  data structures
  ::                                                    ::::
::  the %jael state comes in two parts: absolute
::  and relative.
::
::  ++state-absolute is objective -- defined without
::  reference to our ship.  if you steal someone else's
::  private keys, we have a place to put them.  when
::  others make promises to us, we store them in the
::  same structures we use to make promises to others.
::
::  ++state-relative is subjective, denormalized and
::  derived.  it consists of all the state we need to
::  manage subscriptions efficiently.
::
=>  |%
++  state                                               ::  all vane state
  $:  ver/$0                                            ::  vane version
      yen/(set duct)                                    ::  raw observers
      urb/state-absolute                                ::  all absolute state
      sub/state-relative                                ::  all relative state
      etn=state-eth-node                                ::  eth connection state
      sap=state-snapshots                               ::  state snapshots
  ==                                                    ::
++  state-relative                                      ::  urbit metadata
  $:  $=  bal                                           ::  balance sheet (vest)
        $:  yen/(set duct)                              ::  trackers
        ==                                              ::
      $=  own                                           ::  vault (vein)
        $:  yen/(set duct)                              ::  trackers
            :: XX use this                              ::
            our=ship                                    ::
            sig=(unit oath)                             ::  for a moon
            :: XX reconcile with .dns.eth               ::
            tuf=(list turf)                             ::  domains
            :: XX use for eth replay                    ::
            boq=@ud                                     ::  boot block
            nod=(unit purl:eyre)                        ::  eth gateway
            fak/_|                                      ::  fake keys
            lyf/life                                    ::  version
            jaw/(map life ring)                         ::  private keys
        ==                                              ::
      $=  puk                                           ::  public keys (pubs)
        $:  yen=(jug ship duct)                         ::  trackers
            kyz=(map ship public)                       ::  public key state
        ==                                              ::
      $=  eth                                           ::  ethereum (vent)
        ::TODO  the subscribers here never hear dns or hul...
        $:  yen=(set duct)                              ::  trackers
            dns=dnses                                   ::  on-chain dns state
            hul=(map ship hull)                         ::  on-chain ship state
            ::TODO  do we want (map ship diff-hull) too?
        ==                                              ::
  ==                                                    ::
++  state-absolute                                      ::  absolute urbit
  $:  pry/(map ship (map ship safe))                    ::  promises
      eve=logs                                          ::  on-chain events
  ==                                                    ::
++  state-eth-node                                      ::  node config + meta
  $:  source=(each ship node-src)                       ::  learning from
      heard=(set event-id)                              ::  processed events
      latest-block=@ud                                  ::  last heard block
      foreign-block=@ud                                 ::  node's latest block
  ==                                                    ::
++  state-snapshots                                     ::  rewind points
  $:  interval=_100                                     ::  block interval
      max-count=_10                                     ::  max snaps
      count=@ud                                         ::  length of snaps
      last-block=@ud                                    ::  number of last snap
      snaps=(qeu [block-number=@ud snap=snapshot])      ::  old states
  ==
++  snapshot                                            ::  rewind point
  $:  eve=logs                                          ::  eth absolute state
      sub=state-relative                                ::  all relative state
      etn=state-eth-node                                ::  eth connection state
  ==
++  node-src                                            ::  ethereum node comms
  $:  node=purl:eyre                                    ::  node url
      filter-id=@ud                                     ::  current filter
      poll-timer=@da                                    ::  next filter poll
  ==                                                    ::
::                                                      ::
++  message                                             ::  p2p message
  $%  [%hail p=remote]                                  ::  reset rights
      [%nuke ~]                                         ::  cancel trackers
      [%vent ~]                                         ::  view ethereum events
      [%vent-result p=chain]                            ::  tmp workaround
  ==                                                    ::
++  card                                                ::  i/o action
  (wind note:able gift)                                 ::
::                                                      ::
++  move                                                ::  output
  {p/duct q/card}                                       ::
--  ::
::                                                      ::::
::::                    # light                         ::  light cores
  ::                                                    ::::
=>  |%
::                                                      ::  ++py
::::                    ## sparse/light                 ::  sparse range
  ::                                                    ::::
++  py
  ::  because when you're a star with 2^16 unissued
  ::  planets, a (set) is kind of lame...
  ::
  |_  a/pile
  ::                                                    ::  ++dif:py
  ++  dif                                               ::  add/remove a->b
    |=  b/pile
    ^-  (pair pile pile)
    [(sub(a b) a) (sub b)]
  ::                                                    ::  ++div:py
  ++  div                                               ::  allocate
    |=  b/@ud
    ^-  (unit (pair pile pile))
    =<  ?-(- %& [~ p], %| ~)
    |-  ^-  (each (pair pile pile) @u)
    ?:  =(0 b)
      [%& ~ a]
    ?~  a  [%| 0]
    =/  al  $(a l.a)
    ?-    -.al
        %&  [%& p.p.al a(l q.p.al)]
        %|
      =.  b  (^sub b p.al)
      =/  top  +((^sub q.n.a p.n.a))
      ?:  =(b top)
        [%& a(r ~) r.a]
      ?:  (lth b top)
        :+  %&  a(r ~, q.n (add p.n.a (dec b)))
        =.  p.n.a  (add p.n.a b)
        (uni(a r.a) [n.a ~ ~])
      =/  ar  $(a r.a, b (^sub b top))
      ?-    -.ar
          %&  [%& a(r p.p.ar) q.p.ar]
          %|  [%| :(add top p.al p.ar)]
      ==
    ==
  ::
  ++  gas                                               ::  ++gas:py
    |=  b/(list @)  ^-  pile                            ::  insert list
    ?~  b  a
    $(b t.b, a (put i.b))
  ::                                                    ::  ++gud:py
  ++  gud                                               ::  validate
    =|  {bot/(unit @) top/(unit @)}
    |-  ^-  ?
    ?~  a  &
    ?&  (lte p.n.a q.n.a)
        ?~(top & (lth +(q.n.a) u.top))
        ?~(bot & (gth p.n.a +(u.bot)))
    ::
        ?~(l.a & (vor p.n.a p.n.l.a))
        $(a l.a, top `p.n.a)
    ::
        ?~(l.a & (vor p.n.a p.n.l.a))
        $(a r.a, bot `q.n.a)
    ==
  ::                                                    ::  ++int:py
  ++  int                                               ::  intersection
    |=  b/pile  ^-  pile
    ?~  a  ~
    ?~  b  ~
    ?.  (vor p.n.a p.n.b)  $(a b, b a)
    ?:  (gth p.n.a q.n.b)
      (uni(a $(b r.b)) $(a l.a, r.b ~))
    ?:  (lth q.n.a p.n.b)
      (uni(a $(b l.b)) $(a r.a, l.b ~))
    ?:  (gte p.n.a p.n.b)
      ?:  (lte q.n.a q.n.b)
        [n.a $(a l.a, r.b ~) $(a r.a, l.b ~)]
      [n.a(q q.n.b) $(a l.a, r.b ~) $(l.a ~, b r.b)]
    %-  uni(a $(r.a ~, b l.b))
    ?:  (lte q.n.a q.n.b)
      %-  uni(a $(l.b ~, a r.a))
      [n.b(q q.n.a) ~ ~]
    %-  uni(a $(l.a ~, b r.b))
    [n.b ~ ~]
  ::                                                    ::  ++put:py
  ++  put                                               ::  insert
    |=  b/@  ^-  pile
    (uni [b b] ~ ~)
  ::                                                    ::  ++sub:py
  ++  sub                                               ::  subtract
    |=  b/pile  ^-  pile
    ?~  b  a
    ?~  a  a
    ?:  (gth p.n.a q.n.b)
      $(b r.b, l.a $(a l.a, r.b ~))
    ?:  (lth q.n.a p.n.b)
      $(b l.b, r.a $(a r.a, l.b ~))
    %-  uni(a $(a l.a, r.b ~))
    %-  uni(a $(a r.a, l.b ~))
    ?:  (gte p.n.a p.n.b)
      ?:  (lte q.n.a q.n.b)
        ~
      $(b r.b, a [[+(q.n.b) q.n.a] ~ ~])
    ?:  (lte q.n.a q.n.b)
      $(b l.b, a [[n.a(q (min q.n.a (dec p.n.b)))] ~ ~])
    %-  uni(a $(b r.b, a [[+(q.n.b) q.n.a] ~ ~]))
    $(b l.b, a [[n.a(q (min q.n.a (dec p.n.b)))] ~ ~])
  ::                                                    ::  ++tap:py
  ++  tap                                               ::  into full list
    =|  out/(list @)
    |-  ^+  out
    ?~  a  out
    $(a l.a, out (welp (gulf n.a) $(a r.a)))
  ::                                                    ::  ++uni:py
  ++  uni                                               ::  merge two piles
    |=  b/pile
    ^-  pile
    ?~  b  a
    ?~  a  b
    ?.  (vor p.n.a p.n.b)  $(a b, b a)
    ?:  (lth +(q.n.b) p.n.a)
      $(b r.b, l.a $(a l.a, r.b ~))
    ?:  (lth +(q.n.a) p.n.b)
      $(b l.b, r.a $(a r.a, l.b ~))
    ?:  =(n.a n.b)  [n.a $(a l.a, b l.b) $(a r.a, b r.b)]
    ?:  (lth p.n.a p.n.b)
      ?:  (gth q.n.a q.n.b)
        $(b l.b, a $(b r.b))
      $(b l.b, a $(b r.b, a $(b r.a, r.a ~, q.n.a q.n.b)))
    ?:  (gth q.n.a q.n.b)
      $(a l.a, b $(a r.a, b $(a r.b, r.b ~, q.n.b q.n.a)))
    $(a l.a, b $(a r.a))
  --  ::py
::                                                      ::  ++ry
::::                    ## rights/light                 ::  rights algebra
  ::                                                    ::::
++  ry
  ::
  ::  we need to be able to combine rights, and
  ::  track changes by taking differences between them.
  ::
  ::  ++ry must always crash when you try to make it
  ::  do something that makes no sense.
  ::
  ::  language compromises: the type system can't enforce
  ::  that lef and ryt match, hence the asserts.
  ::
  =<  |_  $:  ::  lef: old right
              ::  ryt: new right
              ::
              lef/rite
              ryt/rite
          ==
      ::                                                ::  ++uni:ry
      ++  uni  ~(sum +> lef ryt)                        ::  add rights
      ::                                                ::  ++dif:ry
      ++  dif                                           ::  r->l: {add remove}
        ^-  (pair (unit rite) (unit rite))
        [~(dif +> ryt lef) ~(dif +> lef ryt)]
      ::                                                ::  ++sub:ry
      ++  sub                                           ::  l - r
        ^-  (unit rite)
        =/  vid  dif
        ~|  vid
        ?>(?=($~ q.vid) p.vid)
      --
  |_  $:  ::  lef: old right
          ::  ryt: new right
          ::
          lef/rite
          ryt/rite
      ==
  ::                                                    ::  ++sub-by:py
  ++  sub-by                                            ::  subtract elements
    |*  {new/(map) old/(map) sub/$-(^ *)}  ^+  new
    %-  ~(rep by new)
    |*  {{key/* val/*} acc/_^+(new ~)}
    =>  .(+<- [key val]=+<-)
    =/  var  (~(get by old) key)
    =.  val  ?~(var val (sub val u.var))
    ?~  val  acc
    (~(put by ,.acc) key val)
  ::                                                    ::  ++dif:ry
  ++  dif                                               ::  in r and not l
    ^-  (unit rite)
    |^  ?-  -.lef
          $apple  ?>(?=($apple -.ryt) (table %apple p.lef p.ryt))
          $block  ?>(?=($block -.ryt) ~)
          $email  ?>(?=($email -.ryt) (sable %email p.lef p.ryt))
          $final  ?>(?=($final -.ryt) (table %final p.lef p.ryt))
          $fungi  ?>(?=($fungi -.ryt) (noble %fungi p.lef p.ryt))
          $guest  ?>(?=($guest -.ryt) ~)
          $hotel  ?>(?=($hotel -.ryt) (bible %hotel p.lef p.ryt))
          $jewel  ?>(?=($jewel -.ryt) (table %jewel p.lef p.ryt))
          $login  ?>(?=($login -.ryt) (sable %login p.lef p.ryt))
          $pword  ?>(?=($pword -.ryt) (ruble %pword p.lef p.ryt))
          $token  ?>(?=($token -.ryt) (ruble %token p.lef p.ryt))
          $urban  ?>(?=($urban -.ryt) (table %urban p.lef p.ryt))
        ==
    ::                                                  ::  ++cable:dif:ry
    ++  cable                                           ::  diff atom
      |*  {nut/@tas new/@ old/@}
      ^-  (unit rite)
      ?:  =(new old)  ~
      `[nut new]
    ::                                                  ::  ++bible:dif:ry
    ++  bible                                           ::  diff pile
      |*  {nut/@tas old/(map dorm pile) new/(map dorm pile)}
      ^-  (unit rite)
      =;  mor/_new
        ?~(mor ~ `[nut mor])
      %^  sub-by  new  old
      |=({a/pile b/pile} (~(sub py a) b))
    ::                                                  ::  ++noble:dif:ry
    ++  noble                                           ::  diff map of @ud
      |*  {nut/@tas old/(map * @ud) new/(map * @ud)}
      ^-  (unit rite)
      =;  mor/_new
        ?~(mor ~ `[nut mor])
      %^  sub-by  new  old
      |=({a/@u b/@u} (sub a (min a b)))
    ::                                                  ::  ++ruble:dif:ry
    ++  ruble                                           ::  diff map of maps
      |*  {nut/@tas old/(map * (map)) new/(map * (map))}
      ^-  (unit rite)
      =;  mor/_new
        ?~(mor ~ `[nut mor])
      %^  sub-by  new  old
      =*  valu  (~(got by new))
      |=  {a/_^+(valu ~) b/_^+(valu ~)}  ^+  a
      (sub-by a b |*({a2/* b2/*} a2))
    ::                                                  ::  ++sable:dif:ry
    ++  sable                                           ::  diff set
      |*  {nut/@tas old/(set) new/(set)}
      ^-  (unit rite)
      =;  mor  ?~(mor ~ `[nut mor])
      (~(dif in new) old)
    ::                                                  ::  ++table:dif:ry
    ++  table                                           ::  diff map
      |*  {nut/@tas old/(map) new/(map)}
      ^-  (unit rite)
      =;  mor  ?~(mor ~ `[nut mor])
      (sub-by new old |*({a/* b/*} a))
    --  ::dif
  ::                                                    ::  ++sum:ry
  ++  sum                                               ::  lef new, ryt old
    ^-  rite
    |^  ?-  -.lef
          $apple  ?>(?=($apple -.ryt) [%apple (table p.lef p.ryt)])
          $block  ?>(?=($block -.ryt) [%block ~])
          $email  ?>(?=($email -.ryt) [%email (sable p.lef p.ryt)])
          $final  ?>(?=($final -.ryt) [%final (table p.lef p.ryt)])
          $fungi  ?>(?=($fungi -.ryt) [%fungi (noble p.lef p.ryt)])
          $guest  ?>(?=($guest -.ryt) [%guest ~])
          $hotel  ?>(?=($hotel -.ryt) [%hotel (bible p.lef p.ryt)])
          $jewel  ?>(?=($jewel -.ryt) [%jewel (table p.lef p.ryt)])
          $login  ?>(?=($login -.ryt) [%login (sable p.lef p.ryt)])
          $pword  ?>(?=($pword -.ryt) [%pword (ruble p.lef p.ryt)])
          $token  ?>(?=($token -.ryt) [%token (ruble p.lef p.ryt)])
          $urban  ?>(?=($urban -.ryt) [%urban (table p.lef p.ryt)])
        ==
    ::                                                  ::  ++bible:uni:ry
    ++  bible                                           ::  union pile
      |=  {new/(map dorm pile) old/(map dorm pile)}
      ^+  new
      %-  (~(uno by old) new)
      |=  (trel dorm pile pile)
      (~(uni py q) r)
    ::                                                  ::  ++noble:uni:ry
    ++  noble                                           ::  union map of @ud
      |=  {new/(map term @ud) old/(map term @ud)}
      ^+  new
      %-  (~(uno by old) new)
      |=  (trel term @ud @ud)
      (add q r)
    ::                                                  ::  ++ruble:uni:ry
    ++  ruble                                           ::  union map of maps
      |=  {new/(map site (map @t @t)) old/(map site (map @t @t))}
      ^+  new
      %-  (~(uno by old) new)
      |=  (trel site (map @t @t) (map @t @t))
      %-  (~(uno by q) r)
      |=  (trel @t @t @t)
      ?>(=(q r) r)
    ::                                                  ::  ++sable:uni:ry
    ++  sable                                           ::  union set
      |*  {new/(set) old/(set)}
      ^+  new
      (~(uni in old) new)
    ::                                                  ::  ++table:uni:ry
    ++  table                                           ::  union map
      |*  {new/(map) old/(map)}
      ^+  new
      %-  (~(uno by old) new)
      |=  (trel _p.-<.new _q.->.new _q.->.new)
      ?>(=(q r) r)
    --  ::uni
  --  ::ry
::                                                      ::  ++up
::::                    ## wallet^light                 ::  wallet algebra
  ::                                                    ::::
++  up
  ::  a set of rites is stored as a tree (++safe), sorted
  ::  by ++gor on the stem, balanced by ++vor on the stem.
  ::  (this is essentially a ++map with stem as key, but
  ::  ++map doesn't know how to link stem and bulb types.)
  ::  the goal of the design is to make it easy to add new
  ::  kinds of rite without a state adapter.
  ::
  ::  wallet operations always crash if impossible;
  ::  %jael has no concept of negative rights.
  ::
  ::  performance issues: ++differ and ++splice, naive.
  ::
  ::  external issues: much copy and paste from ++by.  it
  ::  would be nice to resolve this somehow, but not urgent.
  ::
  ::  language issues: if hoon had an equality test
  ::  that informed inference, ++expose could be
  ::  properly inferred, eliminating the ?>.
  ::
  |_  pig/safe
  ::                                                    ::  ++delete:up
  ++  delete                                            ::  delete right
    |=  ryt/rite
    ^-  safe
    ?~  pig
      ~
    ?.  =(-.ryt -.n.pig)
      ?:  (gor -.ryt -.n.pig)
        [n.pig $(pig l.pig) r.pig]
      [n.pig l.pig $(pig r.pig)]
    =/  dub  ~(sub ry n.pig ryt)
    ?^  dub  [u.dub l.pig r.pig]
    |-  ^-  safe
    ?~  l.pig  r.pig
    ?~  r.pig  l.pig
    ?:  (vor -.n.l.pig -.n.r.pig)
      [n.l.pig l.l.pig $(l.pig r.l.pig)]
    [n.r.pig $(r.pig l.r.pig) r.r.pig]
  ::                                                    ::  ++differ:up
  ++  differ                                            ::  delta pig->gob
    |=  gob/safe
    ^-  bump
    |^  [way way(pig gob, gob pig)]
    ++  way
      %-  intern(pig ~)
      %+  skip  linear(pig gob)
      |=(rite (~(has in pig) +<))
    --
  ::                                                    ::  ++exists:up
  ++  exists                                            ::  test presence
    |=  tag/@tas
    !=(~ (expose tag))
  ::                                                    ::  ++expose:up
  ++  expose                                            ::  typed extract
    |=  tag/@tas
    ^-  (unit rite)
    ?~  pig  ~
    ?:  =(tag -.n.pig)
      [~ u=n.pig]
    ?:((gor tag -.n.pig) $(pig l.pig) $(pig r.pig))
  ::                                                    ::  ++insert:up
  ++  insert                                            ::  insert item
    |=  ryt/rite
    ^-  safe
    ?~  pig
      [ryt ~ ~]
    ?:  =(-.ryt -.n.pig)
      [~(uni ry ryt n.pig) l.pig r.pig]
    ?:  (gor -.ryt -.n.pig)
      =.  l.pig  $(pig l.pig)
      ?>  ?=(^ l.pig)
      ?:  (vor -.n.pig -.n.l.pig)
        [n.pig l.pig r.pig]
      [n.l.pig l.l.pig [n.pig r.l.pig r.pig]]
    =.  r.pig  $(pig r.pig)
    ?>  ?=(^ r.pig)
    ?:  (vor -.n.pig -.n.r.pig)
      [n.pig l.pig r.pig]
    [n.r.pig [n.pig l.pig l.r.pig] r.r.pig]
  ::                                                    ::  ++intern:up
  ++  intern                                            ::  insert list
    |=  lin/(list rite)
    ^-  safe
    ?~  lin  pig
    =.  pig  $(lin t.lin)
    (insert i.lin)
  ::                                                    ::  ++linear:up
  ++  linear                                            ::  convert to list
    =|  lin/(list rite)
    |-  ^+  lin
    ?~  pig  ~
    $(pig r.pig, lin [n.pig $(pig l.pig)])
  ::                                                    ::  ++redact:up
  ++  redact                                            ::  conceal secrets
    |-  ^-  safe
    ?~  pig  ~
    :_  [$(pig l.pig) $(pig r.pig)]
    =*  rys  n.pig
    ^-  rite
    ?+    -.rys  rys
        $apple
      [%apple (~(run by p.rys) |=(@ (shax +<)))]
    ::
        $final
      [%final (~(run by p.rys) |=(@ (shax +<)))]
    ::
        $login
      [%login ~]
    ::
        $pword
      :-  %pword
      %-  ~(run by p.rys)
      |=  (map @ta @t)
      (~(run by +<) |=(@t (fil 3 (met 3 +<) '*')))
    ::
        $jewel
      [%jewel (~(run by p.rys) |=(@ (shax +<)))]
    ::
        $token
      :-  %token
      %-  ~(run by p.rys)
      |=((map @ta @) (~(run by +<) |=(@ (shax +<))))
    ::
        $urban
      [%urban (~(run by p.rys) |=({@da code:ames} [+<- (shax +<+)]))]
    ==
  ::                                                    ::  ++remove:up
  ++  remove                                            ::  pig minus gob
    |=  gob/safe
    ^-  safe
    =/  buv  ~(tap by gob)
    |-  ?~  buv  pig
        $(buv t.buv, pig (delete i.buv))
  ::                                                    ::  ++splice:up
  ++  splice                                            ::  pig plus gob
    |=  gob/safe
    ^-  safe
    =/  buv  ~(tap by gob)
    |-  ?~  buv  pig
        $(buv t.buv, pig (insert i.buv))
  ::                                                    ::  ++update:up
  ++  update                                            ::  arbitrary change
    |=  del/bump
    ^-  safe
    (splice(pig (remove les.del)) mor.del)
  --
::                                                      ::  ++ez
::::                    ## ethereum^light               ::  wallet algebra
  ::                                                    ::::
++  ez
  ::  simple ethereum-related utility arms.
  ::
  |%
  ::
  ::  +order-events: sort changes by block and log numbers
  ::
  ++  order-events
    |=  loz=(list (pair event-id diff-constitution))
    ^+  loz
    %+  sort  loz
    ::  sort by block number, then by event log number,
    ::TODO  then by diff priority.
    |=  [[[b1=@ud l1=@ud] *] [[b2=@ud l2=@ud] *]]
    ?.  =(b1 b2)  (lth b1 b2)
    ?.  =(l1 l2)  (lth l1 l2)
    &
  --
--
::                                                      ::::
::::                    #  heavy                        ::  heavy engines
  ::                                                    ::::
=>  |%
::                                                      ::  ++of
::::                    ## main^heavy                   ::  main engine
  ::                                                    ::::
++  of
  ::  this core handles all top-level %jael semantics,
  ::  changing state and recording moves.
  ::
  ::  logically we could nest the ++su and ++ur cores
  ::  within it, but we keep them separated for clarity.
  ::  the ++curd and ++cure arms complete relative and
  ::  absolute effects, respectively, at the top level.
  ::
  ::  a general pattern here is that we use the ++ur core
  ::  to generate absolute effects (++change), then invoke
  ::  ++su to calculate the derived effect of these changes.
  ::
  ::  for ethereum-related events, this is preceded by
  ::  invocation of ++et, which produces ethereum-level
  ::  changes (++chain). these get turned into absolute
  ::  effects by ++cute.
  ::
  ::  arvo issues: should be merged with the top-level
  ::  vane interface when that gets cleaned up a bit.
  ::
  =|  moz/(list move)
  =|  $:  ::  sys: system context
          ::
          $=  sys
          $:  ::  now: current time
              ::  eny: unique entropy
              ::
              now/@da
              eny/@e
          ==
          ::  all vane state
          ::
          state
      ==
  ::  lex: all durable state
  ::  moz: pending actions
  ::
  =*  lex  ->
  |%
  ::                                                    ::  ++abet:of
  ++  abet                                              ::  resolve
    [(flop moz) lex]
  ::                                                    ::  ++burb:of
  ++  burb                                              ::  per ship
    |=  who/ship
    ~(able ~(ex ur urb) who)
  ::                                                    ::  ++scry:of
  ++  scry                                              ::  read
    |=  {syd/@tas pax/path}
    ~|  %jael-scry-of-stub
    =^  mar  pax  =/(a (flop pax) [-.a (flop t.+.a)])
    !!
  ::                                                    ::  ++sein:of
  ++  sein                                              ::  sponsor
    |=  who=ship
    ^-  ship
    ::  XX save %dawn sponsor in .own.sub, check there
    ::
    =/  hul  (~(get by hul.eth.sub) who)
    ?:  ?&  ?=(^ hul)
            ?=(^ net.u.hul)
            ?=(^ sponsor.u.net.u.hul)
        ==
      u.sponsor.u.net.u.hul
    ::  XX fall back to most recent sponsor instead?
    ::
    (^sein:title who)
  ::                                                    ::  ++saxo:of
  ++  saxo                                              ::  sponsorship chain
    |=  who/ship
    ^-  (list ship)
    =/  dad  (sein who)
    [who ?:(=(who dad) ~ $(who dad))]
  ::                                                    ::  ++call:of
  ++  call                                              ::  invoke
    |=  $:  ::  hen: event cause
            ::  tac: event data
            ::
            hen/duct
            tac/task
        ==
    ^+  +>
    ?-    -.tac
    ::
    ::  destroy promises
    ::    {$burn p/ship q/safe}
    ::
        $burn
      %^  cure  hen  our.tac
      abet:abet:(deal:(burb our.tac) p.tac [~ q.tac])
    ::
    ::  boot from keys
    ::    $:  $dawn
    ::        =seed
    ::        spon=(unit ship)
    ::        czar=(map ship [=life =pass])
    ::        turf=(list turf)}
    ::        bloq=@ud
    ::        node=purl
    ::    ==
    ::
        %dawn
      =*  our  who.seed.tac
      ::  sort-of single-homed
      ::
      =.  our.own.sub  our
      ::  save our boot block
      ::
      =.  boq.own.sub  bloq.tac
      ::  save our ethereum gateway (required for galaxies)
      ::
      =.  nod.own.sub  node.tac
      ::  save our parent signature (only for moons)
      ::
      =.  sig.own.sub  sig.seed.tac
      ::  our initial public key
      ::
      =.  kyz.puk.sub
        =/  cub  (nol:nu:crub:crypto key.seed.tac)
        %+  ~(put by kyz.puk.sub)
          our
        [& lyf.seed.tac (my [lyf.seed.tac pub:ex:cub] ~)]
      ::  our initial private key, as a +tree of +rite
      ::
      =/  rit  (sy [%jewel (my [lyf.seed.tac key.seed.tac] ~)] ~)
      =.  +>.$  $(tac [%mint our our rit])
      ::  our initial galaxy table as a +map from +life to +public
      ::
      =/  kyz
        %-  ~(run by czar.tac)
        |=([=life =pass] `public`[live=| life (my [life pass] ~)])
      =.  +>.$
        %-  curd  =<  abet
        (pubs:~(feel su hen our urb sub etn sap) kyz)
      ::  XX save sponsor in .own.sub
      ::  XX reconcile with .dns.eth
      ::  set initial domains
      ::
      =.  tuf.own.sub  turf.tac
      ::
      =.  moz
        %+  weld  moz
        ::  order is crucial!
        ::
        ::    %dill must init after %gall
        ::    the %give init (for unix) must be after %dill init
        ::    %jael init must be deferred (makes http requests)
        ::
        ^-  (list move)
        :~  [hen %pass /(scot %p our)/init %b %wait +(now.sys)]
            [hen %give %init our]
            [hen %slip %e %init our]
            [hen %slip %d %init our]
            [hen %slip %g %init our]
            [hen %slip %c %init our]
            [hen %slip %a %init our]
        ==
      +>.$
    ::
    ::  boot fake
    ::    {$fake our/ship}
    ::
        %fake
      =*  our  our.tac
      ::  sort-of single-homed
      ::
      =.  our.own.sub  our
      ::  fake keys are deterministically derived from the ship
      ::
      =/  cub  (pit:nu:crub:crypto 512 our)
      ::  save our parent signature (only for moons)
      ::
      ::    XX move logic to zuse
      ::
      =.  sig.own.sub
        ?.  ?=(%earl (clan:title our))
          ~
        =/  yig  (pit:nu:crub:crypto 512 (^sein:title our))
        [~ (sign:as:yig (shaf %earl (sham our 1 pub:ex:cub)))]
      ::  our initial public key
      ::
      =.  kyz.puk.sub
        (~(put by kyz.puk.sub) our [& 1 (my [1 pub:ex:cub] ~)])
      ::  our private key, as a +tree of +rite
      ::
      ::    Private key updates are disallowed for fake ships,
      ::    so we do this first.
      ::
      =/  rit  (sy [%jewel (my [1 sec:ex:cub] ~)] ~)
      =.  +>.$  $(tac [%mint our our rit])
      ::  set the fake bit
      ::
      =.  fak.own.sub  &
      ::  initialize other vanes per the usual procedure
      ::
      ::    Except for ourselves!
      ::
      =.  moz
        %+  weld  moz
        ^-  (list move)
        :~  [hen %give %init our]
            [hen %slip %e %init our]
            [hen %slip %d %init our]
            [hen %slip %g %init our]
            [hen %slip %c %init our]
            [hen %slip %a %init our]
        ==
      +>.$
    ::
    ::  remote update
    ::    {$hail p/ship q/remote}
    ::
        $hail
      %^  cure  hen  our.tac
      abet:abet:(hail:(burb our.tac) p.tac q.tac)
    ::
    ::  set ethereum source
    ::    [%look p=(each ship purl)]
    ::
        %look
      %^  cute  hen  our.tac  =<  abet
      (~(look et our.tac now.sys urb.lex sub.lex etn.lex sap.lex) src.tac)
    ::
    ::  create promises
    ::    {$mint p/ship q/safe}
    ::
        $mint
      ~|  %fake-jael
      ?<  ?&  fak.own.sub
              (~(exists up q.tac) %jewel)
          ==
      %^  cure  hen  our.tac
      abet:abet:(deal:(burb our.tac) p.tac [q.tac ~])
    ::
    ::
    ::  move promises
    ::    {$move p/ship q/ship r/safe}
    ::
        $move
      =.  +>
        %^  cure  hen  our.tac
        abet:abet:(deal:(burb our.tac) p.tac [~ r.tac])
      =.  +>
        %^  cure  hen  our.tac
        abet:abet:(deal:(burb our.tac) q.tac [r.tac ~])
      +>
    ::
    ::  cancel all trackers from duct
    ::    {$nuke $~}
    ::
        $nuke
      %_  +>
        yen          (~(del in yen) hen)
        yen.bal.sub  (~(del in yen.bal.sub) hen)
        yen.own.sub  (~(del in yen.own.sub) hen)
        yen.eth.sub  (~(del in yen.eth.sub) hen)
      ==
    ::
    ::  watch public keys
    ::    [%pubs our=ship who=ship]
    ::
        %pubs
      %-  curd  =<  abet
      (~(pubs ~(feed su hen our.tac urb sub etn sap) hen) who.tac)
    ::
    ::  seen after breach
    ::    [%meet our=ship who=ship]
    ::
        %meet
      %^  cure  hen  our.tac
      [[%meet who.tac life.tac pass.tac]~ urb]
    ::
    ::  XX should be a subscription
    ::  XX reconcile with .dns.eth
    ::  request domains
    ::    [%turf ~]
    ::
        %turf
      ::  ships with real keys must have domains,
      ::  those with fake keys must not
      ::
      ?<  =(fak.own.sub ?=(^ tuf.own.sub))
      +>.$(moz [[hen %give %turf tuf.own.sub] moz])
    ::
    ::  watch private keys
    ::    {$vein $~}
    ::
        $vein
      (curd abet:~(vein ~(feed su hen our.tac urb sub etn sap) hen))
    ::
    ::  watch ethereum events
    ::    [%vent ~]
    ::
        %vent
      =.  moz  [[hen %give %mack ~] moz]
      (curd abet:~(vent ~(feed su hen our.tac urb sub etn sap) hen))
    ::
    ::  monitor assets
    ::    {$vest $~}
    ::
        $vest
      (curd abet:~(vest ~(feed su hen our.tac urb sub etn sap) hen))
    ::
    ::  monitor all
    ::    {$vine $~}
    ::
        $vine
      +>(yen (~(put in yen) hen))
    ::
    ::  authenticated remote request
    ::    {$west p/ship q/path r/*}
    ::
        $west
      =+  mes=((hard message) r.tac)
      =*  our  p.p.tac
      =*  dem  q.p.tac
      ?-    -.mes
      ::
      ::  reset remote rights
      ::    [%hail p=remote]
      ::
          %hail
        %^  cure  hen  our
        abet:abet:(hail:(burb our) dem p.mes)
      ::
      ::  cancel trackers
      ::    [%nuke ~]
      ::
          %nuke
        $(tac mes)
      ::
      ::  view ethereum events
      ::    [%vent ~]
      ::
          %vent
        ~&  %west-vent
        $(tac [%vent our])
      ::
      ::
          %vent-result
        ::  ignore if not from currently configured source.
        ?.  &(-.source.etn =(dem p.source.etn))
          +>.$
        =.  moz  [[hen %give %mack ~] moz]
        %^  cute  hen  our  =<  abet
        (~(hear-vent et our now.sys urb.lex sub.lex etn.lex sap.lex) p.mes)
      ==
    ::
    ::  rewind to snapshot
    ::    {$wind p/@ud}
    ::
        %wind
      (wind hen our.tac p.tac)
    ==
  ::
  ++  take
    |=  [tea=wire hen=duct hin=sign]
    ^+  +>
    ?>  ?=([@ *] tea)
    =+  our=(slav %p i.tea)
    =*  wir  t.tea
    ?-  hin
        [%a %woot *]
      ?~  q.hin  ~&(%coop-fine +>.$)
      ?~  u.q.hin  ~&(%ares-fine +>.$)
      ~&  [%woot-bad p.u.u.q.hin]
      ~_  q.u.u.q.hin
      ::TODO  fail:et
      +>.$
    ::
        [%e %sigh *]
      %^  cute  hen  our  =<  abet
      (~(sigh et our now.sys urb.lex sub.lex etn.lex sap.lex) wir p.hin)
    ::
        [%b %wake ~]
      %^  cute  hen  our
      ::  XX cleanup
      ::
      ?.  ?=([%init ~] wir)
        abet:~(wake et our now.sys urb.lex sub.lex etn.lex sap.lex)
      abet:(~(init et our now.sys [urb sub etn sap]:lex) our (sein our))
    ::
        [%j %vent *]
      %^  cute  hen  our  =<  abet
      (~(hear-vent et our now.sys urb.lex sub.lex etn.lex sap.lex) p.hin)
    ==
  ::                                                    ::  ++curd:of
  ++  curd                                              ::  relative moves
    |=  $:  moz/(list move)
            sub/state-relative
            etn/state-eth-node
            sap/state-snapshots
        ==
    +>(sub sub, etn etn, sap sap, moz (weld (flop moz) ^moz))
  ::                                                    ::  ++cure:of
  ++  cure                                              ::  absolute edits
    |=  {hen/duct our/ship hab/(list change) urb/state-absolute}
    ^+  +>
    (curd(urb urb) abet:(~(apex su hen our urb sub etn sap) hab))
  ::                                                    ::  ++cute:of
  ++  cute                                              ::  ethereum changes
    |=  $:  hen=duct
            our=ship
            mos=(list move)
            ven=chain
            urb=state-absolute
            sub=state-relative
            etn=state-eth-node
            sap=state-snapshots
        ==
    ^+  +>
    %-  cure(urb urb, sub sub, etn etn, sap sap, moz (weld (flop mos) moz))
    [hen our abet:(link:(burb our) ven)]
  ::                                                    ::  ++wind:of
  ++  wind                                              ::  rewind to snap
    |=  [hen=duct our=@p block=@ud]
    ^+  +>
    ~&  %dripping
    =/  old-qeu  snaps.sap
    =:  snaps.sap       ~
        count.sap       0
        last-block.sap  0
      ==
    =^  snap=snapshot  +>.$
      ?:  |(=(~ old-qeu) (lth block block-number:(need ~(top to old-qeu))))
        [%*(. *snapshot latest-block.etn launch:contracts) +>.$]
      |-  ^-  [snapshot _+>.^$]
      ::  =^  [new-qeu=(qeu [block-number=@ud snap=snapshot]) snap=snapshot]  snaps.sap
      =^  snap=[block-number=@ud snap=snapshot]  old-qeu
        ~(get to old-qeu)
      =:  count.sap       +(count.sap)
          last-block.sap  block-number.snap
          snaps.sap       (~(put to snaps.sap) snap)
        ==
      ?:  |(=(~ old-qeu) (lth block block-number:(need ~(top to old-qeu))))
        [snap.snap +>.^$]
      $
    ~&  [%wind block latest-block.etn.snap ~(wyt by hul.eth.sub.snap)]
    ::  keep the following in sync with ++extract-snap:file:su
    %=  +>.$
      eve.urb   eve.snap
      etn       etn.snap(source source.etn)
      sap       sap(last-block 0)
      sub       %=  sub.snap
                  yen.bal  yen.bal.sub
                  yen.own  yen.own.sub
                  yen.puk  yen.puk.sub
                  yen.eth  yen.eth.sub
                ==
    ::
      moz       =-  [[hen %pass /wind/look %j %look our -] moz]
                ?-  -.source.etn
                  %&  &+p.source.etn
                  %|  |+node.p.source.etn
                ==
    ==
  --
::                                                      ::  ++su
::::                    ## relative^heavy               ::  subjective engine
  ::                                                    ::::
++  su
      ::  the ++su core handles all derived state,
      ::  subscriptions, and actions.
      ::
      ::  ++feed:su registers subscriptions.
      ::
      ::  ++feel:su checks if a ++change should notify
      ::  any subscribers.
      ::
      ::  ++fire:su generates outgoing network messages.
      ::
      ::  ++form:su generates the actual report data.
      ::
  =|  moz/(list move)
  =|  evs=logs
  =|  $:  hen/duct
          our/ship
          state-absolute
          state-relative
          state-eth-node
          state-snapshots
      ==
  ::  moz: moves in reverse order
  ::  urb: absolute urbit state
  ::  sub: relative urbit state
  ::
  =*  urb  ->+<
  =*  sub  ->+>-
  =*  etn  ->+>+<
  =*  sap  ->+>+>
  |%
  ::                                                    ::  ++abet:su
  ++  abet                                              ::  resolve
    ::TODO  we really want to just send the %give, but ames is being a pain.
    :: =>  (exec yen.eth [%give %vent |+evs])
    =>  ?~  evs  .
        (vent-pass yen.eth |+evs)
    [(flop moz) sub etn sap]
  ::                                                    ::  ++apex:su
  ++  apex                                              ::  apply changes
    |=  hab/(list change)
    ^+  +>
    ?~  hab  +>
    %=    $
        hab  t.hab
        +>
      ?-  -.i.hab
        %ethe  (file can.i.hab)
        %meet  (meet +.i.hab)
        %rite  (paid +.i.hab)
      ==
    ==
  ::                                                    ::  ++exec:su
  ++  exec                                              ::  mass gift
    |=  {yen/(set duct) cad/card}
    =/  noy  ~(tap in yen)
    |-  ^+  ..exec
    ?~  noy  ..exec
    $(noy t.noy, moz [[i.noy cad] moz])
  ::
  ++  vent-pass
    |=  [yen=(set duct) res=chain]
    =+  yez=~(tap in yen)
    |-  ^+  ..vent-pass
    ?~  yez  ..vent-pass
    =*  d  i.yez
    ?>  ?=([[%a @ @ *] *] d)
    =+  our=(slav %p i.t.i.d)
    =+  who=(slav %p i.t.t.i.d)
    %+  exec  [d ~ ~]
    :+  %pass
      /(scot %p our)/vent-result
    ^-  note:able
    [%a %want [our who] /j/(scot %p our)/vent-result %vent-result res]
  ::                                                    ::  ++feed:su
  ++  feed                                              ::  subscribe to view
    |_  ::  hen: subscription source
        ::
        hen/duct
    ::
    ++  pubs
      |=  who=ship
      ?:  fak.own.sub
        (pubs:fake who)
      %_  ..feed
        moz      =/  pub  (~(get by kyz.puk) who)
                 ?~  pub  moz
                 ?:  =(0 life.u.pub)  moz
                 [[hen %give %pubs u.pub] moz]
        yen.puk  (~(put ju yen.puk) who hen)
      ==
    ::                                                  ::  ++vein:feed:su
    ++  vein                                            ::  private keys
      %_  ..feed
        moz      [[hen %give %vein [lyf jaw]:own] moz]
        yen.own  (~(put in yen.own) hen)
      ==
    ::                                                  ::  ++vest:feed:su
    ++  vest                                            ::  balance
      %_  ..feed
        moz      [[hen %give %vest %& vest:form] moz]
        yen.bal  (~(put in yen.bal) hen)
      ==
    ::
    ++  vent
      %.  [[hen ~ ~] &+eve]
      %_  vent-pass
      :: %_  ..feed  ::TODO  see ++abet
        :: moz      [[hen %give %vent &+eve] moz]
        yen.eth  (~(put in yen.eth) hen)
      ==
    ::                                                  ::  ++fake:feed:su
    ++  fake                                            ::  fake subs and state
      ?>  fak.own.sub
      |%
      ++  pubs
        |=  who=ship
        =/  cub  (pit:nu:crub:crypto 512 who)
        =/  pub  [live=| life=1 (my [1 pub:ex:cub] ~)]
        =.  moz  [[hen %give %pubs pub] moz]
        (pubs:feel (my [who pub] ~))
      --
    --
  ::                                                    ::  ++feel:su
  ++  feel                                              ::  update tracker
    |%
    ::                                                  ::  ++pubs:feel:su
    ++  pubs                                            ::  kick public keys
      ::  puz: new public key states
      ::
      |=  puz=(map ship public)
      =/  pus  ~(tap by puz)
      ::
      ::  process change for each ship separately
      ::  XX check for diffs before sending?
      ::
      |-  ^+  ..feel
      ?~  pus  ..feel
      =;  fel  $(pus t.pus, ..feel fel)
      =*  who  p.i.pus
      =*  pub  q.i.pus
      ::
      ::  update public key store and notify subscribers
      ::  of the new state
      ::
      ~&  [%sending-pubs-about who life.pub live.pub]
      %+  exec(kyz.puk (~(put by kyz.puk) who pub))
        (~(get ju yen.puk) who)
      [%give %pubs pub]
    ::                                                  ::  ++vein:feel:su
    ++  vein                                            ::  kick private keys
      ^+  ..feel
      =/  yam  vein:form
      ?:  &(=(lyf.own p.yam) =(jaw.own q.yam))
        ..feel
      =.  lyf.own  p.yam
      =.  jaw.own  q.yam
      (exec yen.own [%give %vein lyf.own jaw.own])
    ::                                                  ::  ++vest:feel:su
    ++  vest                                            ::  kick balance
      |=  hug/action
      ^+  ..feel
      ?:  =([~ ~] +.q.hug)  ..feel
      ::
      ::  notify all local listeners
      ::
      =.  ..feel  (exec yen.bal [%give %vest %| p.hug q.hug])
      ::
      ::  pig: purse report for partner
      ::
      ?.  ?=(%| -.q.hug)  ..feel
      =*  pig  (~(lawn ur urb) our p.hug)
      %_    ..feel
          moz
        :_  moz
        :^  *duct  %pass  /vest/(scot %p p.hug)
        :+  %a  %want
        :+  [our p.hug]  /j
        ^-  message
        [%hail |+pig]
      ==
    ::
    ++  vent
      |=  can=chain
      ^+  ..feel
      ::TODO  see ++abet
      :: (exec yen.eth [%give %vent can])
      (vent-pass yen.eth can)
    --
  ::                                                    ::  ++form:su
  ++  form                                              ::  generate reports
    |%
    ::                                                  ::  ++vein:form:su
    ++  vein                                            ::  private key report
      ^-  (pair life (map life ring))
      (~(lean ur urb) our)
    ::                                                  ::  ++vest:form:su
    ++  vest                                            ::  balance report
      ^-  balance
      :-  ::
          ::  raw: all our liabilities by ship
          ::  dud: delete liabilities to self
          ::  cul: mask secrets
          ::
          =*  raw  =-(?~(- ~ u.-) (~(get by pry.urb) our))
          =*  dud  (~(del by raw) our)
          =*  cul  (~(run by dud) |=(safe ~(redact up +<)))
          cul
      ::
      ::  fub: all assets by ship
      ::  veg: all nontrivial assets, secrets masked
      ::
      =/  fub
        ^-  (list (pair ship (unit safe)))
        %+  turn
          ~(tap by pry.urb)
        |=  (pair ship (map ship safe))
        [p (~(get by q) our)]
      =*  veg
        |-  ^-  (list (pair ship safe))
        ?~  fub  ~
        =+  $(fub t.fub)
        ?~(q.i.fub - [[p.i.fub ~(redact up u.q.i.fub)] -])
      ::
      (~(gas by *(map ship safe)) veg)
    --
  ::                                                    ::  ++paid:su
  ++  paid                                              ::  track asset change
    |=  $:  ::  rex: promise from
            ::  pal: promise to
            ::  del: change to existing
            ::
            rex/ship
            pal/ship
            del/bump
        ==
    ^+  +>
    ::  ignore empty delta; keep secrets out of metadata
    ::
    ?:  =([~ ~] del)  +>
    =.  del  [~(redact up mor.del) ~(redact up les.del)]
    ?.  =(our pal)
      ::
      ::  track promises we made to others
      ::
      ?.  =(our rex)  +>
      ::
      ::  track liabilities
      ::
      (vest:feel pal %& del)
    ::
    ::  track private keys
    ::
    ?.  (~(exists up mor.del) %jewel)  +>
    vein:feel
  ::                                                    ::  ++meet:su
  ++  meet                                              ::  seen after breach
    |=  [who=ship =life =pass]
    ^+  +>
    =;  new=public
      (pubs:feel (my [who new] ~))
    ::
    =/  old=(unit public)
      (~(get by kyz.puk) who)
    ?:  ?|  ?=(?(%earl %pawn) (clan:title who))
            ::  XX save %dawn sponsor in .own.sub, check there
            ::  XX or move sein:of to sein:su?
            ::  XX full saxo chain?
            ::
            =(who (^sein:title our))
        ==
      ?~  old
        [live=& life (my [life pass] ~)]
      =/  fyl  life.u.old
      =/  sap  (~(got by pubs.u.old) fyl)
      ~|  [%met-mismatch who life=[old=fyl new=life] pass=[old=sap new=pass]]
      ?>  ?:  =(fyl life)
            =(sap pass)
          =(+(fyl) life)
      [live=& life (~(put by pubs.u.old) life pass)]
    ?.  ?=(^ old)
      ~|  [%met-unknown-ship who]  !!
    =/  fyl  life.u.old
    =/  sap  (~(got by pubs.u.old) fyl)
    ~|  [%met-mismatch who life=[old=fyl new=life] pass=[old=sap new=pass]]
    ?>  &(=(fyl life) =(sap pass))
    [live=& life pubs.u.old]
  ::                                                    ::  ++file:su
  ++  file                                              ::  process event logs
    ::TODO  whenever we add subscriptions for data,
    ::      outsource the updating of relevant state
    ::      to a ++feel arm.
    |=  [new=? evs=logs]
    ^+  +>
    =?  +>  new
      ::TODO  should we be mutating state here,
      ::      or better to move this into ++vent:feel?
      +>(dns.eth *dnses, hul.eth ~, kyz.puk ~)
    =?  +>  |(new !=(0 ~(wyt by evs)))
      %-  vent:feel
      ?:(new &+evs |+evs)
    ::
    =+  vez=(order-events:ez ~(tap by evs))
    =|  kyz=(map ship public)
    |^  ?~  vez  (pubs:feel kyz)
        =^  kyn  ..file  (file-event i.vez)
        $(vez t.vez, kyz kyn)
    ::
    ++  get-public
      |=  who=ship
      ^-  public
      %+  fall  (~(get by kyz) who)
      ::NOTE  we can only do this because ++pubs:feel
      ::      sends out entire new state, rather than
      ::      just the processed changes.
      %+  fall  (~(get by kyz.puk) who)
      %*(. *public live |)
    ::
    ++  file-keys
      |=  [who=ship =life =pass]
      ^+  kyz
      =/  pub  (get-public who)
      =/  puk  (~(get by pubs.pub) life)
      ?^  puk
        ::  key known, nothing changes
        ~|  [%key-mismatch who life `@ux`u.puk `@ux`pass (get-public ~zod)]
        ?>(=(u.puk pass) kyz)
      %+  ~(put by kyz)  who
      :+  live.pub
        (max life life.pub)
      (~(put by pubs.pub) life pass)
    ::
    ++  file-discontinuity
      |=  who=ship
      ^+  kyz
      =+  (get-public who)
      (~(put by kyz) who -(live |))
    ::
    ++  file-event
      |=  [wer=event-id dif=diff-constitution]
      ^+  [kyz ..file]
      ?:  (~(has in heard) wer)
        ~&  %ignoring-already-heard-event
        [kyz ..file]
      ::
      ::  sanity check, should never fail if we operate correctly
      ::  XX is this true in the presence of reorgs?
      ::
      ::  ?>  (gte block.wer latest-block)
      =:  evs           (~(put by evs) wer dif)
          heard         (~(put in heard) wer)
          latest-block  (max latest-block block.wer)
      ==
      =^  kyz  ..file
        ?-  -.dif
          %hull   ~|(wer=wer (file-hull +.dif))
          %dns    [kyz (file-dns +.dif)]
        ==
      [kyz (file-snap wer)]
    ::
    ++  file-hull
      |=  [who=ship dif=diff-hull]
      ^+  [kyz ..file]
      =-  ::TODO  =; with just the type
        ?:  ?=(%& -.new)
          :-  (file-keys who p.new)
          ..file(hul.eth (~(put by hul.eth) who hel))
        ?:  p.new
          :-  kyz
          ..file(hul.eth (~(put by hul.eth) who hel))
        :-  (file-discontinuity who)
        %=  ..file
          hul.eth  (~(put by hul.eth) who hel)
          ::  these must be appended here; +abet flops them
          ::
          moz  =/  lyf=life
                 ~|  sunk-unknown+who
                 life:(~(got by kyz.puk))
               %+  weld  moz
               ^-  (list move)
               :~  [hen %slip %a %sunk who lyf]
                   [hen %slip %c %sunk who lyf]
                   [hen %slip %d %sunk who lyf]
                   [hen %slip %e %sunk who lyf]
                   [hen %slip %f %sunk who lyf]
                   [hen %slip %g %sunk who lyf]
               ==
        ==
      ::  hel: updated hull
      ::  new: new keypair or "kept continuity?" (yes is no-op)
      ^-  [hel=hull new=(each (pair life pass) ?)]
      =+  hul=(fall (~(get by hul.eth) who) *hull)
      ::
      ::  sanity checks, should never fail if we operate correctly
      ::
      ~|  [%diff-order-insanity -.dif who (~(get by hul.eth) who)]
      ?>  ?+  -.dif  &
            %spawned      ?>  ?=(^ kid.hul)
                          !(~(has in spawned.u.kid.hul) who.dif)
            %keys         ?>  ?=(^ net.hul)
                          =(life.dif +(life.u.net.hul))
            %continuity   ?>  ?=(^ net.hul)
                          =(new.dif +(continuity-number.u.net.hul))
          ==
      ::
      ::  apply hull changes, catch continuity and key changes
      ::
      :-  (apply-hull-diff hul dif)
      =*  nop  |+&  ::  no-op
      ?+  -.dif  nop
        %continuity   |+|
        %keys         &+[life pass]:dif
        %full         ?~  net.new.dif  nop
                      ::TODO  do we want/need to do a diff-check
                      &+[life pass]:u.net.new.dif
      ==
    ::
    ++  file-dns
      |=  dns=dnses
      ..file(dns.eth dns)
    ::
    ++  file-snap                                       ::  save snapshot
      |=  wer=event-id
      ^+  ..file
      =?    sap
          %+  lth  2
          %+  sub.add
            (div block.wer interval.sap)
          (div last-block.sap interval.sap)
        ~&  :*  %snap  count=count.sap  max-count=max-count.sap 
                last-block=last-block.sap  interval=interval.sap
                lent=(lent ~(tap to snaps.sap))
            ==
        %=  sap
          snaps       (~(put to snaps.sap) block.wer extract-snap)
          count       +(count.sap)
          last-block  block.wer
        ==
      =?  sap  (gth count.sap max-count.sap)
        ~&  :*  %dump  count=count.sap  max-count=max-count.sap 
                lent=(lent ~(tap to snaps.sap))
            ==
        %=  sap
          snaps  +:~(get to snaps.sap)
          count  (dec count)
        ==
      ..file
    ::
    ++  extract-snap                                    ::  extract rewind point
      ^-  snapshot
      :*  eve.urb
          %=  sub
            yen.bal  ~
            yen.own  ~
            yen.puk  ~
            yen.eth  ~
          ==
          %=  etn
            source  *(each ship node-src)
          ==
      ==
    --
  --
::                                                      ::  ++ur
::::                    ## absolute^heavy               ::  objective engine
  ::                                                    ::::
++  ur
      ::  the ++ur core handles primary, absolute state.
      ::  it is the best reference for the semantics of
      ::  the urbit pki.
      ::
      ::  it is absolutely verboten to use [our] in ++ur.
      ::
  =|  hab/(list change)
  =|  state-absolute
  ::
  ::  hab: side effects, reversed
  ::  urb: all urbit state
  ::
  =*  urb  -
  |%
  ::                                                    ::  ++abet:ur
  ++  abet                                              ::  resolve
    [(flop hab) `state-absolute`urb]
  ::
  ++  link
    |=  ven=chain
    %_  +>
      hab   [[%ethe ven] hab]
      eve   ?:  ?=(%& -.ven)  p.ven
            (~(uni by eve) p.ven)
    ==
  ::                                                    ::  ++lawn:ur
  ++  lawn                                              ::  debts, rex to pal
    |=  {rex/ship pal/ship}
    ^-  safe
    (lawn:~(able ex rex) pal)
  ::                                                    ::  ++lean:ur
  ++  lean                                              ::  private keys
    |=  rex/ship
    ^-  (pair life (map life ring))
    lean:~(able ex rex)
  ::                                                    ::  ++ex:ur
  ++  ex                                                ::  server engine
    ::  shy: private state
    ::  rug: domestic will
    ::
    =|  $:  shy/(map ship safe)
        ==
    =|  ::  rex: server ship
        ::
        rex/ship
    |%
    ::                                                  ::  ++abet:ex:ur
    ++  abet                                            ::  resolve
      %_  ..ex
        pry  (~(put by pry) rex shy)
      ==
    ::                                                  ::  ++able:ex:ur
    ++  able                                            ::  initialize
      %_  .
        shy  (fall (~(get by pry) rex) *(map ship safe))
      ==
    ::                                                  ::  ++deal:ex:ur
    ++  deal                                            ::  alter rights
      |=  {pal/ship del/bump}
      ^+  +>
      =/  gob  (fall (~(get by shy) pal) *safe)
      =*  hep  (~(update up gob) del)
      %_  +>.$
        shy  (~(put by shy) pal hep)
        hab  [[%rite rex pal del] hab]
      ==
    ::
    ++  hail                                            ::  ++hail:ex:ur
      |=  {pal/ship rem/remote}                         ::  report rights
      ^+  +>
      =/  gob  (fall (~(get by shy) pal) *safe)
      ::  yer: pair of change and updated safe.
      =/  yer  ^-  (pair bump safe)
        ?-  -.rem
          ::  change: add rem. result: old + rem.
          %&  [[p.rem ~] (~(splice up gob) p.rem)]
          ::  change: difference. result: rem.
          %|  [(~(differ up gob) p.rem) p.rem]
        ==
      %_  +>.$
        shy  (~(put by shy) pal q.yer)
        hab  [[%rite rex pal p.yer] hab]
      ==
    ::                                                  ::  ++lean:ex:ur
    ++  lean                                            ::  private keys
      ^-  (pair life (map life ring))
      ::
      ::  par: promises by rex, to rex
      ::  jel: %jewel rights
      ::  lyf: latest life of
      ::
      =*  par  (~(got by shy) rex)
      =/  jel=rite  (need (~(expose up par) %jewel))
      ?>  ?=($jewel -.jel)
      =;  lyf=life
        [lyf p.jel]
      %+  roll  ~(tap in ~(key by p.jel))
      |=  [liv=life max=life]
      ?:((gth liv max) liv max)
    ::                                                  ::  ++lawn:ex:ur
    ++  lawn                                            ::  liabilities to pal
      |=  pal/ship
      ^-  safe
      =-(?~(- ~ u.-) (~(get by shy) pal))
    --
  --
::                                                      ::  ++et
::::                    ## ethereum^heavy               ::  ethereum engine
  ::                                                    ::::
++  et
  ::
  ::  the ++et core handles all logic necessary to maintain the
  ::  absolute record of on-chain state changes, "events".
  ::
  ::  we either subscribe to a parent ship's existing record, or
  ::  communicate directly with an ethereum node.
  ::
  ::  moves: effects; either behn timers, subscriptions,
  ::         or ethereum node rpc requests.
  ::  reset: whether the found changes assume a fresh state.
  ::  changes: on-chain changes heard from our source.
  ::
  =|  moves=(list move)
  =+  reset=|
  =|  changes=logs
  =|  $:  our=ship
          now=@da
          state-absolute
          state-relative
          state-eth-node
          state-snapshots
      ==
  =*  urb  ->+<
  =*  sub  ->+>-
  =*  etn  ->+>+<
  =*  sap  ->+>+>
  ::
  ::  +|  outward
  |%
  ::
  ::  +abet: produce results
  ::
  ++  abet
    ^-  $:  (list move)  chain  state-absolute  state-relative
            state-eth-node  state-snapshots
        ==
    [(flop moves) ?:(reset &+changes |+changes) urb sub etn sap]
  ::
  ::  +put-move: store side-effect
  ::
  ++  put-move
    |=  mov=move
    %_(+> moves [mov moves])
  ::
  ::  +put-request: store rpc request to ethereum node
  ::
  ++  put-request
    |=  [wir=wire id=(unit @t) req=request]
    (put-move (rpc-hiss wir (request-to-json id req)))
  ::
  ::  +put-change: store change made by event
  ::
  ++  put-change
    |=  [cause=event-id dif=diff-constitution]
    ?:  (~(has by changes) cause)  ::  one diff per event
      ~&  [%duplicate-cause cause]
      !!
    +>(changes (~(put by changes) cause dif))
  ::
  ::  +|  move-generation
  ::
  ::  +wrap-note: %pass a note using a made-up duct
  ::
  ++  wrap-note
    |=  [wir=wire not=note:able]
    ^-  move
    :-  [/jael/eth-logic ~ ~]
    [%pass (weld /(scot %p our) wir) not]
  ::
  ::  +rpc-hiss: make an http request to our ethereum rpc source
  ::
  ++  rpc-hiss
    |=  [wir=wire jon=json]
    ^-  move
    %+  wrap-note  wir
    :^  %e  %hiss  ~
    :+  %json-rpc-response  %hiss
    ?>  ?=(%| -.source)
    !>  (json-request node.p.source jon)
  ::
  ::  +|  source-operations
  ::
  ::  +listen-to-ship: depend on who for ethereum events
  ::
  ++  listen-to-ship
    |=  [our=ship who=ship]
    %-  put-move(source &+who)
    %+  wrap-note  /vent/(scot %p who)
    [%a %want [our who] /j/(scot %p our)/vent `*`[%vent ~]]
  ::
  ::  +unsubscribe-from-source: stop listening to current source ship
  ::
  ++  unsubscribe-from-source
    |=  our=ship
    %-  put-move
    ?>  ?=(%& -.source)
    %+  wrap-note  /vent/(scot %p p.source)
    ::TODO  should we maybe have a %nuke-vent,
    ::      or do we have a unique duct here?
    [%a %want [our p.source] /j/(scot %p our)/vent `*`[%nuke ~]]
  ::
  ::  +listen-to-node: start syncing from a node
  ::
  ::    Get latest block from eth node and compare to our own latest block.
  ::    Get intervening blocks in chunks until we're caught up, then set
  ::    up a filter going forward.
  ::
  ++  listen-to-node
    |=  url=purl:eyre
    get-latest-block(source |+%*(. *node-src node url))
  ::
  ::  +|  catch-up-operations
  ::
  ::  +get-latest-block
  ::
  ::    Get latest known block number from eth node.
  ::
  ++  get-latest-block
    (put-request /catch-up/block-number `'block number' %eth-block-number ~)
  ::
  ::  +catch-up: get next chunk
  ::
  ++  catch-up
    |=  from-block=@ud
    ?:  (gte from-block foreign-block)
      new-filter
    =/  next-block  (min foreign-block (add from-block 5.760)) ::  ~d1
    ~&  [%catching-up from=from-block to=foreign-block]
    %-  put-request
    :+  /catch-up/step/(scot %ud from-block)/(scot %ud next-block)
      `'catch up'
    :*  %eth-get-logs
        `number+from-block
        `number+next-block
        ~[ships:contracts]
        ~
    ==
  ::
  ::  +|  filter-operations
  ::
  ::  +new-filter: request a new polling filter
  ::
  ::    Listens only to the Ships state contract, and only from
  ::    the last-heard block onward.
  ::
  ++  new-filter
    %-  put-request
    :+  /filter/new  `'new filter'
    :*  %eth-new-filter
        `number+latest-block
        ::  XX We want to load from a snapshot at least 40 blocks behind, then
        ::  replay to the present
        ::  `[%number ?:((lte latest-block 40) 0 (sub.add latest-block 40))]
        ::TODO  or Ships origin block when 0
        ~  ::TODO  we should probably chunck these, maybe?
        ::  https://stackoverflow.com/q/49339489
        ~[ships:contracts]
        ~
    ==
  ::
  ::  +read-filter: get all events the filter captures
  ::
  ++  read-filter
    ?>  ?=(%| -.source)
    %-  put-request
    :+  /filter/logs  `'filter logs'
    [%eth-get-filter-logs filter-id.p.source]
  ::
  ::  +poll-filter: get all new events since the last poll (or filter creation)
  ::
  ++  poll-filter
    ?>  ?=(%| -.source)
    ?:  =(0 filter-id.p.source)
      ~&  %no-filter-bad-poll
      .
    %-  put-request
    :+  /filter/changes  `'poll filter'
    [%eth-get-filter-changes filter-id.p.source]
  ::
  ::  +wait-poll: remind us to poll in four minutes
  ::
  ::    Four minutes because Ethereum RPC filters time out after five.
  ::    We don't check for an existing timer or clear an old one here,
  ::    sane flows shouldn't see this being called superfluously.
  ::
  ++  wait-poll
    ?>  ?=(%| -.source)
    =+  wen=(add now ~m4)
    %-  put-move(poll-timer.p.source wen)
    (wrap-note /poll %b %wait wen)
  ::
  ::  +cancel-wait-poll: remove poll reminder
  ::
  ++  cancel-wait-poll
    ?>  ?=(%| -.source)
    %-  put-move(poll-timer.p.source *@da)
    %+  wrap-note  /poll/cancel
    [%b %rest poll-timer.p.source]
  ::
  ::  +|  configuration
  ::
  ::  +init: initialize with default ethereum connection
  ::
  ::    for galaxies, we default to a localhost geth node.
  ::    for stars and under, we default to the parent ship.
  ::
  ++  init
    |=  [our=ship bos=ship]
    ^+  +>
    ::  TODO: ship or node as sample?
    ::
    =.  latest-block  launch:contracts
    ?:  |(=(our bos) ?=(^ nod.own))
      ~|  %jael-init-node
      (listen-to-node (need nod.own))
    (listen-to-ship our bos)
  ::
  ::  +look: configure the source of ethereum events
  ::
  ++  look
    |=  src=(each ship purl:eyre)
    ^+  +>
    =.  +>
      ?:  ?=(%| -.source)
        cancel-wait-poll
      (unsubscribe-from-source our)
    ?:  ?=(%| -.src)
      (listen-to-node p.src)
    (listen-to-ship our p.src)
  ::
  ::  +|  subscription-results
  ::
  ::  +hear-vent: process incoming events
  ::
  ++  hear-vent
    |=  can=chain
    ^+  +>
    ?-  -.can
      %&   (assume p.can)
      ::
        %|
      =+  evs=~(tap by p.can)
      |-
      ?~  evs  +>.^$
      =.  +>.^$  (accept i.evs)
      $(evs t.evs)
    ==
  ::
  ::  +assume: clear state and process events
  ::
  ++  assume
    |=  evs=logs
    ^+  +>
    %.  |+evs
    %_  hear-vent
      heard         ~
      latest-block  0
      reset         &
    ==
  ::
  ::  +accept: process single event
  ::
  ++  accept
    |=  [cause=event-id dif=diff-constitution]
    ^+  +>
    ?:  (~(has in heard) cause)
      ~&  %accept-ignoring-duplicate-event
      +>.$
    (put-change cause dif)
  ::
  ::  +|  filter-results
  ::
  ::  +wake: kick polling, unless we changed source
  ::
  ++  wake
    ?.  ?=(%| -.source)  .
    poll-filter
  ::
  ::  +sigh: parse rpc response and process it
  ::
  ++  sigh
    |=  [cuz=wire mar=mark res=vase]
    ^+  +>
    ?:  ?=(%& -.source)  +>
    ?:  ?=(%tang mar)
      ::TODO  proper error handling
      ~_  q.res
      ~&  [%yikes cuz]
      +>.$
    ?>  ?=(%json-rpc-response mar)
    =+  rep=~|(res ((hard response:rpc:jstd) q.res))
    ?:  ?=(%fail -.rep)
      ?:  =(405 p.hit.rep)
        ~&  'HTTP 405 error (expected if using infura)'
        +>.$
      ?.  =(5 (div p.hit.rep 100))
        ~&  [%http-error hit.rep]
        +>.$
      ?+  cuz
        ~&  [%retrying-node ((soft tang) q.res)]
        wait-poll
          [%catch-up %step @ta @ta ~]
        ~&  %retrying-catch-up
        (catch-up (slav %ud `@ta`i.t.t.cuz))
      ==
    ?+  cuz  ~|([%weird-sigh-wire cuz] !!)
        [%filter %new *]
      (take-new-filter rep)
    ::
        [%filter *]
      (take-filter-results rep)
    ::
        [%catch-up %block-number ~]
      (take-block-number rep)
    ::
        [%catch-up %step @ta @ta ~]
      =/  from-block  (slav %ud `@ta`i.t.t.cuz)
      =/  next-block  (slav %ud `@ta`i.t.t.t.cuz)
      (take-catch-up-step rep from-block next-block)
    ==
  ::
  ::  +take-new-filter: store filter-id and read it
  ::
  ++  take-new-filter
    |=  rep=response:rpc:jstd
    ^+  +>
    ~|  rep
    ?<  ?=(%batch -.rep)
    ?<  ?=(%fail -.rep)
    ?:  ?=(%error -.rep)
      ~&  [%filter-error--retrying message.rep]
      new-filter
    ?>  ?=(%| -.source)
    =-  read-filter(filter-id.p.source -)
    (parse-eth-new-filter-res res.rep)
  ::
  ::  +take-filter-results: parse results into event-logs and process them
  ::
  ++  take-filter-results
    |=  rep=response:rpc:jstd
    ^+  +>
    ?<  ?=(%batch -.rep)
    ?<  ?=(%fail -.rep)
    ?:  ?=(%error -.rep)
      ?.  ?|  =('filter not found' message.rep)  ::  geth
              =('Filter not found' message.rep)  ::  parity
          ==
        ~&  [%unhandled-filter-error +.rep]
        +>
      ~&  [%filter-timed-out--recreating block=latest-block +.rep]
      new-filter
    ::  kick polling timer, only if it hasn't already been.
    =?  +>  ?&  ?=(%| -.source)
                (gth now poll-timer.p.source)
            ==
      wait-poll
    (take-events rep)
  ::
  ::  +take-block-number: take block number and start catching up
  ::
  ++  take-block-number
    |=  rep=response:rpc:jstd
    ^+  +>
    ?<  ?=(%batch -.rep)
    ?<  ?=(%fail -.rep)
    ?:  ?=(%error -.rep)
      ~&  [%take-block-number-error--retrying message.rep]
      get-latest-block
    =.  foreign-block  (parse-eth-block-number res.rep)
    ~&  [%setting-foreign-block foreign-block]
    (catch-up latest-block)
  ::
  ::  +take-catch-up-step: process chunk
  ::
  ++  take-catch-up-step
    |=  [rep=response:rpc:jstd from-block=@ud next-block=@ud]
    ^+  +>
    ?<  ?=(%batch -.rep)
    ?<  ?=(%fail -.rep)
    ?:  ?=(%error -.rep)
      ~&  [%catch-up-step-error--retrying message.rep]
      (catch-up from-block)
    ::  XX file
    =.  +>.$  (take-events rep)
    (catch-up next-block)
  ::
  ::  +take-events: process events
  ::
  ++  take-events
    |=  rep=response:rpc:jstd
    ^+  +>
    ?<  ?=(%batch -.rep)
    ?<  ?=(%fail -.rep)
    ?<  ?=(%error -.rep)
    ?.  ?=(%a -.res.rep)
      ~&  [%events-not-array rep]
      !!
    =*  changes  p.res.rep
    ~?  (gth (lent changes) 0)
      :*  %processing-changes
          changes=(lent changes)
          block=latest-block
          id=?.(?=(%| -.source) ~ `@ux`filter-id.p.source)
      ==
    |-  ^+  +>.^$
    ?~  changes  +>.^$
    =.  +>.^$
      (take-event-log (parse-event-log i.changes))
    $(changes t.changes)
  ::
  ::  +take-event-log: obtain changes from event-log
  ::
  ++  take-event-log
    |=  log=event-log
    ^+  +>
    ?~  mined.log
      ~&  %ignoring-unmined-event
      +>
    =*  place  u.mined.log
    ::
    ::TODO  if the block number is less than latest, that means we got
    ::      events out of order somehow and should probably reset.
    ::      This could also mean there was a chain reorg if the logs
    ::      have the 'removed' tag set.  In this case, we should delete
    ::      the old logs.  Finally, since we rewind 40 blocks on new
    ::      filter, this could be up to 40 blocks old just because of
    ::      that.
    ::  ~?  (lte block-number.place latest-block)
    ::    [%old-block block-number.place latest-block]
    ::
    ?:  (~(has in heard) block-number.place log-index.place)
      ?.  removed.u.mined.log
        ::  ~&  [%ignoring-duplicate-event tx=transaction-hash.u.mined.log]
        +>
      ~&  :*  'removed event!  Perhaps chain has reorganized?'
              tx-hash=transaction-hash.u.mined.log
              block-number=block-number.u.mined.log
              block-hash=block-hash.u.mined.log
          ==
      +>  ::TODO  undo the effects of this event
    =+  cuz=[block-number.place log-index.place]
    ::
    ?:  =(event.log changed-dns:ships-events)
      =+  ^-  [pri=tape sec=tape ter=tape]
        %+  decode-results  data.log
        ~[%string %string %string]
      %+  put-change  cuz
      [%dns (crip pri) (crip sec) (crip ter)]
    ::
    =+  dif=(event-log-to-hull-diff log)
    ?~  dif  +>.$
    (put-change cuz %hull u.dif)
  ::
  --
--
::                                                      ::::
::::                    #  vane                         ::  interface
  ::                                                    ::::
::
::  lex: all durable %jael state
::
=|  lex/state
|=  $:  ::
        ::  now: current time
        ::  eny: unique entropy
        ::  ski: namespace resolver
        ::
        now/@da
        eny/@e
        ski/sley
    ==
|%
::                                                      ::  ++call
++  call                                                ::  request
  |=  $:  ::  hen: cause of this event
          ::  hic: event data
          ::
          hen/duct
          hic/(hypo (hobo task:able))
      ==
  ^-  {p/(list move) q/_..^$}
  =^  did  lex
    =-  abet:(~(call of [now eny] lex) hen -)
    ?.  ?=($soft -.q.hic)  q.hic
    ((hard task:able) p.q.hic)
  [did ..^$]
::                                                      ::  ++load
++  load                                                ::  upgrade
  |=  $:  ::  old: previous state
          ::
          old/state
      ==
  ^+  ..^$
  ..^$(lex old)
::                                                      ::  ++scry
++  scry                                                ::  inspect
  |=  $:  ::  fur: event security
          ::  ren: access mode
          ::  why: owner
          ::  syd: desk (branch)
          ::  lot: case (version)
          ::  tyl: rest of path
          ::
          fur/(unit (set monk))
          ren/@tas
          why/shop
          syd/desk
          lot/coin
          tyl/spur
      ==
  ^-  (unit (unit cage))
  ::  XX security
  ::
  ?.  =(lot [%$ %da now])  ~
  ?.  =(%$ ren)  [~ ~]
  ?+    syd
      ~
  ::
      %life
    ?.  ?=([@ ~] tyl)  [~ ~]
    ?.  ?&  ?=(%& -.why)
            (~(has by pry.urb.lex) p.why)
        ==
      [~ ~]
    =/  who  (slaw %p i.tyl)
    ?~  who  [~ ~]
    ::  fake ships always have life=1
    ::
    ?:  fak.own.sub.lex
      ``[%atom !>(1)]
    ?:  =(u.who p.why)
      ``[%atom !>(lyf.own.sub.lex)]
    =/  pub  (~(get by kyz.puk.sub.lex) u.who)
    ?~  pub  ~
    ``[%atom !>(life.u.pub)]
  ::
      %deed
    ?.  ?=([@ @ ~] tyl)  [~ ~]
    ?.  &(?=(%& -.why) =(p.why our.own.sub.lex))
      [~ ~]
    =/  who  (slaw %p i.tyl)
    =/  lyf  (slaw %ud i.t.tyl)
    ?~  who  [~ ~]
    ?~  lyf  [~ ~]
    =/  rac  (clan:title u.who)
    ::
    ?:  ?=(%pawn rac)
      ?.  =(u.who p.why)
        [~ ~]
      ?.  =(1 u.lyf)
        [~ ~]
      =/  sec  (~(got by jaw.own.sub.lex) u.lyf)
      =/  cub  (nol:nu:crub:crypto sec)
      =/  sig  (sign:as:cub (shaf %self (sham [u.who 1 pub:ex:cub])))
      :^  ~  ~  %noun
      !>  ^-  deed:ames
      [1 pub:ex:cub `sig]
    ::
    ?:  ?=(%earl rac)
      ?.  =(u.who p.why)
        [~ ~]
      ?:  (gth u.lyf lyf.own.sub.lex)
        ~
      ?:  (lth u.lyf lyf.own.sub.lex)
        [~ ~]
      =/  sec  (~(got by jaw.own.sub.lex) u.lyf)
      =/  cub  (nol:nu:crub:crypto sec)
      :^  ~  ~  %noun
      !>  ^-  deed:ames
      [u.lyf pub:ex:cub sig.own.sub.lex]
    ::
    =/  pub  (~(get by kyz.puk.sub.lex) u.who)
    ?~  pub  ~
    :: XX check lyf
    ::
    :^  ~  ~  %noun
    !>  ^-  deed:ames
    [life.u.pub (~(got by pubs.u.pub) life.u.pub) ~]
  ::
      %earl
    ?.  ?=([@ @ @ ~] tyl)  [~ ~]
    ?.  ?&  ?=(%& -.why)
            (~(has by pry.urb.lex) p.why)
        ==
      [~ ~]
    =/  who  (slaw %p i.tyl)
    =/  lyf  (slaw %ud i.t.tyl)
    =/  pub  (slaw %ux i.t.t.tyl)
    ?~  who  [~ ~]
    ?~  lyf  [~ ~]
    ?~  pub  [~ ~]
    ?:  (gth u.lyf lyf.own.sub.lex)
      ~
    ?:  (lth u.lyf lyf.own.sub.lex)
      [~ ~]
    :: XX check that who/lyf hasn't been booted
    ::
    =/  sec  (~(got by jaw.own.sub.lex) u.lyf)
    =/  cub  (nol:nu:crub:crypto sec)
    =/  sig  (sign:as:cub (shaf %earl (sham u.who u.lyf u.pub)))
    ``[%atom !>(sig)]
  ::
      %sein
    ?.  ?=([@ ~] tyl)  [~ ~]
    ?.  ?&  ?=(%& -.why)
            (~(has by pry.urb.lex) p.why)
        ==
      [~ ~]
    =/  who  (slaw %p i.tyl)
    ?~  who  [~ ~]
    :^  ~  ~  %atom
    !>  ^-  ship
    (~(sein of [now eny] lex) u.who)
  ::
      %saxo
    ?.  ?=([@ ~] tyl)  [~ ~]
    ?.  ?&  ?=(%& -.why)
            (~(has by pry.urb.lex) p.why)
        ==
      [~ ~]
    =/  who  (slaw %p i.tyl)
    ?~  who  [~ ~]
    :^  ~  ~  %noun
    !>  ^-  (list ship)
    (~(saxo of [now eny] lex) u.who)
  ::
      %snap
    ?.  ?=(~ tyl)  [~ ~]
    ?:  =(~ snaps.sap.lex)
      `~
    :^  ~  ~  %noun  !>
    %=  sap.lex
        snaps
      %-  ~(put to *(qeu [block-number=@ud snap=snapshot]))
      |-  ^-  [@ud snapshot]
      =^  snap  snaps.sap.lex
        ~(get to snaps.sap.lex)
      ?:  =(~ snaps.sap.lex)
        snap
      $
    ==
  ==
::                                                      ::  ++stay
++  stay                                                ::  preserve
  lex
::                                                      ::  ++take
++  take                                                ::  accept
  |=  $:  ::  tea: order
          ::  hen: cause
          ::  hin: result
          ::
          tea/wire
          hen/duct
          hin/(hypo sign)
      ==
  ^-  {p/(list move) q/_..^$}
  =^  did  lex  abet:(~(take of [now eny] lex) tea hen q.hin)
  [did ..^$]
--
