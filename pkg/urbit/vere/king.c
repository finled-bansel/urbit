/* vere/daemon.c
**
** the main loop of the daemon process
*/
#include <curl/curl.h>
#include <unistd.h>
#include <uv.h>
#include "all.h"
#include "vere/vere.h"

#include "ivory.h"

//  stash config flags for worker
//
static c3_w sag_w;

/*
::  skeleton client->king protocol
::
|%
::  +doom: daemon command
::
::    Should require auth to the daemon itself
::
+$  doom
  $%  ::  boot
      ::
      ::  p: boot procedure
      ::  q: pill specifier
      ::  r: path to pier
      ::
      [%boot p=boot q=pill r=@t]
      ::  end the daemon
      ::
      ::    XX not implemented
      ::
      [%exit ~]
      ::  acquire a pier
      ::
      ::    XX used for restart, may not be right
      ::
      [%pier p=(unit @t)]
      ::  admin ship actions
      ::
      ::    XX not implemented
      ::
      [%root p=ship q=wyrd]
  ==
::  +boot: boot procedures
::
+$  boot
  $%  ::  mine a comet
      ::
      ::  p: optionally under a specific star
      ::
      [%come p=(unit ship)]
      ::  boot with real keys
      ::
      ::    And perform pre-boot validation, retrieve snapshot, etc.
      ::
      [%dawn p=seed]
      ::  boot with fake keys
      ::
      ::  p: identity
      ::
      [%fake p=ship]
  ==
::  +pill: boot-sequence ingredients
::
+$  pill
  %+  each
    ::  %&: complete pill (either +brass or +solid)
    ::
    ::  p: jammed pill
    ::  q: optional %into ovum overriding that of .p
    ::
    [p=@ q=(unit ovum)]
  ::  %|: incomplete pill (+ivory)
  ::
  ::    XX not implemented, needs generation of
  ::    %veer ova for install %zuse and the vanes
  ::
  ::  p: jammed pill
  ::  q: module ova
  ::  r: userspace ova
  ::
  [p=@ q=(list ovum) r=(list ovum)]
--
*/

void _daemon_doom(u3_noun doom);
  void _daemon_boot(u3_noun boot);
    void _daemon_come(u3_noun star, u3_noun pill, u3_noun path);
    void _daemon_dawn(u3_noun seed, u3_noun pill, u3_noun path);
    void _daemon_fake(u3_noun ship, u3_noun pill, u3_noun path);
  void _daemon_pier(u3_noun pier);

/* _daemon_defy_fate(): invalid fate
*/
void
_daemon_defy_fate()
{
  exit(1);
}

/* _daemon_doom(): doom parser
*/
void
_daemon_doom(u3_noun doom)
{
  u3_noun load;
  void (*next)(u3_noun);

  c3_assert(_(u3a_is_cell(doom)));
  c3_assert(_(u3a_is_cat(u3h(doom))));

  switch ( u3h(doom) ) {
    case c3__boot:
      next = _daemon_boot;
      break;
    case c3__pier:
      next = _daemon_pier;
      break;
    default:
      _daemon_defy_fate();
  }

  load = u3k(u3t(doom));
  u3z(doom);
  next(load);
}

/* _daemon_boot(): boot parser
*/
void
_daemon_boot(u3_noun bul)
{
  u3_noun boot, pill, path;
  void (*next)(u3_noun, u3_noun, u3_noun);

  c3_assert(_(u3a_is_cell(bul)));
  u3x_trel(bul, &boot, &pill, &path);
  c3_assert(_(u3a_is_cat(u3h(boot))));

  switch ( u3h(boot) ) {
    case c3__fake: {
      next = _daemon_fake;
      break;
    }
    case c3__come: {
      next = _daemon_come;
      break;
    }
    case c3__dawn: {
      next = _daemon_dawn;
      break;
    }
    default:
      return _daemon_defy_fate();
  }

  next(u3k(u3t(boot)), u3k(pill), u3k(path));
  u3z(bul);
}

/* _daemon_fake(): boot with fake keys
*/
void
_daemon_fake(u3_noun ship, u3_noun pill, u3_noun path)
{
  u3_pier_boot(sag_w, ship, u3nc(c3__fake, u3k(ship)), pill, path);
}

/* _daemon_come(): mine a comet under star (unit)
**
**   XX revise to exclude star argument
*/
void
_daemon_come(u3_noun star, u3_noun pill, u3_noun path)
{
  _daemon_dawn(u3_dawn_come(), pill, path);
}

static void
_daemon_slog(u3_noun hod)
{
  u3_pier_tank(0, 0, u3k(u3t(hod)));
  u3z(hod);
}

/* _daemon_dawn(): boot from keys, validating
*/
void
_daemon_dawn(u3_noun seed, u3_noun pill, u3_noun path)
{
  // enable ivory slog printfs
  //
  u3C.slog_f = _daemon_slog;

  u3_pier_boot(sag_w, u3k(u3h(seed)), u3_dawn_vent(seed), pill, path);

  // disable ivory slog printfs
  //
  u3C.slog_f = 0;
}

/* _daemon_pier(): pier parser
*/
void
_daemon_pier(u3_noun pier)
{
  if ( (c3n == u3du(pier)) ||
       (c3n == u3ud(u3t(pier))) ) {
    u3m_p("daemon: invalid pier", pier);
    exit(1);
  }

  u3_pier_stay(sag_w, u3k(u3t(pier)));
  u3z(pier);
}

/* _daemon_curl_alloc(): allocate a response buffer for curl
**  XX deduplicate with dawn.c
*/
static size_t
_daemon_curl_alloc(void* dat_v, size_t uni_t, size_t mem_t, uv_buf_t* buf_u)
{
  size_t siz_t = uni_t * mem_t;
  buf_u->base = c3_realloc(buf_u->base, 1 + siz_t + buf_u->len);

  memcpy(buf_u->base + buf_u->len, dat_v, siz_t);
  buf_u->len += siz_t;
  buf_u->base[buf_u->len] = 0;

  return siz_t;
}

/* _daemon_get_atom(): HTTP GET url_c, produce the response body as an atom.
**  XX deduplicate with dawn.c
*/
static u3_noun
_daemon_get_atom(c3_c* url_c)
{
  CURL *curl;
  CURLcode result;
  long cod_l;

  uv_buf_t buf_u = uv_buf_init(c3_malloc(1), 0);

  if ( !(curl = curl_easy_init()) ) {
    u3l_log("failed to initialize libcurl\n");
    exit(1);
  }

  curl_easy_setopt(curl, CURLOPT_CAINFO, u3K.certs_c);
  curl_easy_setopt(curl, CURLOPT_URL, url_c);
  curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, _daemon_curl_alloc);
  curl_easy_setopt(curl, CURLOPT_WRITEDATA, (void*)&buf_u);

  result = curl_easy_perform(curl);
  curl_easy_getinfo(curl, CURLINFO_RESPONSE_CODE, &cod_l);

  //  XX retry?
  //
  if ( CURLE_OK != result ) {
    u3l_log("failed to fetch %s: %s\n",
            url_c, curl_easy_strerror(result));
    exit(1);
  }
  if ( 300 <= cod_l ) {
    u3l_log("error fetching %s: HTTP %ld\n", url_c, cod_l);
    exit(1);
  }

  curl_easy_cleanup(curl);

  {
    u3_noun pro = u3i_bytes(buf_u.len, (const c3_y*)buf_u.base);

    c3_free(buf_u.base);

    return pro;
  }
}

/* _get_cmd_output(): Run a shell command and capture its output.
   Exits with an error if the command fails or produces no output.
   The 'out_c' parameter should be an array of sufficient length to hold
   the command's output, up to a max of len_c characters.
*/
static void
_get_cmd_output(c3_c *cmd_c, c3_c *out_c, c3_w len_c)
{
  FILE *fp = popen(cmd_c, "r");
  if ( NULL == fp ) {
    u3l_log("'%s' failed\n", cmd_c);
    exit(1);
  }

  if ( NULL == fgets(out_c, len_c, fp) ) {
    u3l_log("'%s' produced no output\n", cmd_c);
    exit(1);
  }

  pclose(fp);
}

/* _arvo_hash(): get a shortened hash of the last git commit
   that modified the sys/ directory in arvo.
   hax_c must be an array with length >= 11.
*/
static void
_arvo_hash(c3_c *out_c, c3_c *arv_c)
{
  c3_c cmd_c[2048];

  sprintf(cmd_c, "git -C %s log -1 HEAD --format=%%H -- sys/", arv_c);
  _get_cmd_output(cmd_c, out_c, 11);

  out_c[10] = 0;  //  end with null-byte
}

/* _git_pill_url(): produce a URL from which to download a pill
   based on the location of an arvo git repository.
*/
static void
_git_pill_url(c3_c *out_c, c3_c *arv_c)
{
  c3_c hax_c[11];

  assert(NULL != arv_c);

  if ( 0 != system("which git >> /dev/null") ) {
    u3l_log("boot: could not find git executable\r\n");
    exit(1);
  }

  _arvo_hash(hax_c, arv_c);
  sprintf(out_c, "https://bootstrap.urbit.org/git-%s.pill", hax_c);
}

/* _boothack_pill(): parse CLI pill arguments into +pill specifier
*/
static u3_noun
_boothack_pill(void)
{
  u3_noun arv = u3_nul;
  u3_noun pil;

  if ( 0 != u3_Host.ops_u.pil_c ) {
    u3l_log("boot: loading pill %s\r\n", u3_Host.ops_u.pil_c);
    pil = u3m_file(u3_Host.ops_u.pil_c);
  }
  else {
    c3_c url_c[2048];

    if ( (c3y == u3_Host.ops_u.git) &&
       (0 != u3_Host.ops_u.arv_c) )
    {
      _git_pill_url(url_c, u3_Host.ops_u.arv_c);
    }
    else {
      c3_assert( 0 != u3_Host.ops_u.url_c );
      strcpy(url_c, u3_Host.ops_u.url_c);
    }

    u3l_log("boot: downloading pill %s\r\n", url_c);
    pil = _daemon_get_atom(url_c);
  }

  if ( 0 != u3_Host.ops_u.arv_c ) {
    u3l_log("boot: preparing filesystem from %s\r\n",
            u3_Host.ops_u.arv_c);
    arv = u3nc(u3_nul, u3_unix_initial_into_card(u3_Host.ops_u.arv_c));
  }

  return u3nt(c3y, pil, arv);
}

/* _boothack_key(): parse a private key file or value
*/
static u3_noun
_boothack_key(u3_noun kef)
{
  u3_noun seed, ship;

  {
    u3_noun des = u3dc("slaw", c3__uw, u3k(kef));

    if ( u3_nul == des ) {
      c3_c* kef_c = u3r_string(kef);
      u3l_log("dawn: invalid private keys: %s\r\n", kef_c);
      c3_free(kef_c);
      exit(1);
    }

    //  +seed:able:jael: private key file
    //
    u3_noun pro = u3m_soft(0, u3ke_cue, u3k(u3t(des)));
    if ( u3_blip != u3h(pro) ) {
      u3l_log("dawn: unable to cue private key\r\n");
      exit(1);
    }
    seed = u3k(u3t(pro));
    u3z(pro);

    //  local reference, not counted
    //
    ship = u3h(seed);
    u3z(des);
    u3z(kef);
  }

  if ( 0 != u3_Host.ops_u.who_c ) {
    u3_noun woh = u3i_string(u3_Host.ops_u.who_c);
    u3_noun whu = u3dc("slaw", 'p', u3k(woh));

    if ( u3_nul == whu ) {
      u3l_log("dawn: invalid ship specified with -w %s\r\n",
              u3_Host.ops_u.who_c);
      exit(1);
    }

    if ( c3n == u3r_sing(ship, u3t(whu)) ) {
      u3_noun how = u3dc("scot", 'p', u3k(ship));
      c3_c* how_c = u3r_string(u3k(how));
      u3l_log("dawn: mismatch between -w %s and -K %s\r\n",
              u3_Host.ops_u.who_c, how_c);

      u3z(how);
      c3_free(how_c);
      exit(1);
    }

    u3z(woh);
    u3z(whu);
  }

  return seed;
}

/* _boothack_doom(): parse CLI arguments into $doom
*/
static u3_noun
_boothack_doom(void)
{
  u3_noun pax = u3i_string(u3_Host.dir_c);
  u3_noun bot;

  if ( c3n == u3_Host.ops_u.nuu ) {
    return u3nt(c3__pier, u3_nul, pax);
  }
  else if ( 0 != u3_Host.ops_u.fak_c ) {
    u3_noun fak = u3i_string(u3_Host.ops_u.fak_c);
    u3_noun whu = u3dc("slaw", 'p', u3k(fak));

    if ( u3_nul == whu ) {
      u3l_log("boot: malformed -F ship %s\r\n", u3_Host.ops_u.fak_c);
      exit(1);
    }

    bot = u3nc(c3__fake, u3k(u3t(whu)));

    u3z(whu);
    u3z(fak);
  }
  else if ( 0 != u3_Host.ops_u.who_c ) {
    u3_noun kef;

    if ( 0 != u3_Host.ops_u.key_c ) {
      kef = u3m_file(u3_Host.ops_u.key_c);

      // handle trailing newline
      //
      {
        c3_c* key_c = u3r_string(kef);
        c3_w  len_w = strlen(key_c);

        if (len_w && (key_c[len_w - 1] == '\n')) {
          key_c[len_w - 1] = '\0';
          u3z(kef);
          kef = u3i_string(key_c);
        }

        c3_free(key_c);
      }
    }
    else if ( 0 != u3_Host.ops_u.gen_c ) {
      kef = u3i_string(u3_Host.ops_u.gen_c);
    }
    else {
      u3l_log("boot: must specify a key with -k or -G\r\n");
      exit(1);
    }

    bot = u3nc(c3__dawn, _boothack_key(kef));
  }
  else {
    //  XX allow parent star to be specified?
    //
    bot = u3nc(c3__come, u3_nul);
  }

  return u3nq(c3__boot, bot, _boothack_pill(), pax);
}

/* _daemon_sign_init(): initialize daemon signal handlers
*/
static void
_daemon_sign_init(void)
{
  //  gracefully shutdown on SIGTERM
  //
  {
    u3_usig* sig_u;

    sig_u = c3_malloc(sizeof(u3_usig));
    uv_signal_init(u3L, &sig_u->sil_u);

    sig_u->num_i = SIGTERM;
    sig_u->nex_u = u3_Host.sig_u;
    u3_Host.sig_u = sig_u;
  }

  //  forward SIGINT to worker
  //
  {
    u3_usig* sig_u;

    sig_u = c3_malloc(sizeof(u3_usig));
    uv_signal_init(u3L, &sig_u->sil_u);

    sig_u->num_i = SIGINT;
    sig_u->nex_u = u3_Host.sig_u;
    u3_Host.sig_u = sig_u;
  }

  //  inject new dimensions after terminal resize
  //
  {
    u3_usig* sig_u;

    sig_u = c3_malloc(sizeof(u3_usig));
    uv_signal_init(u3L, &sig_u->sil_u);

    sig_u->num_i = SIGWINCH;
    sig_u->nex_u = u3_Host.sig_u;
    u3_Host.sig_u = sig_u;
  }

  //  handle SIGQUIT (turn it into SIGABRT)
  //
  {
    u3_usig* sig_u;

    sig_u = c3_malloc(sizeof(u3_usig));
    uv_signal_init(u3L, &sig_u->sil_u);

    sig_u->num_i = SIGQUIT;
    sig_u->nex_u = u3_Host.sig_u;
    u3_Host.sig_u = sig_u;
  }
}

/* _daemon_sign_cb: signal callback.
*/
static void
_daemon_sign_cb(uv_signal_t* sil_u, c3_i num_i)
{
  switch ( num_i ) {
    default: {
      u3l_log("\r\nmysterious signal %d\r\n", num_i);
      break;
    }

    case SIGTERM: {
      u3_pier_exit(u3_pier_stub());
      break;
    }

    case SIGINT: {
      u3l_log("\r\ninterrupt\r\n");
      u3_term_ef_ctlc();
      break;
    }

    case SIGWINCH: {
      u3_term_ef_winc();
      break;
    }

    case SIGQUIT: {
      abort();
    }
  }
}

/* _daemon_sign_move(): enable daemon signal handlers
*/
static void
_daemon_sign_move(void)
{
  u3_usig* sig_u;

  for ( sig_u = u3_Host.sig_u; sig_u; sig_u = sig_u->nex_u ) {
    uv_signal_start(&sig_u->sil_u, _daemon_sign_cb, sig_u->num_i);
  }
}

/* _daemon_sign_hold(): disable daemon signal handlers
*/
static void
_daemon_sign_hold(void)
{
  u3_usig* sig_u;

  for ( sig_u = u3_Host.sig_u; sig_u; sig_u = sig_u->nex_u ) {
    uv_signal_stop(&sig_u->sil_u);
  }
}

/* _daemon_sign_close(): dispose daemon signal handlers
*/
static void
_daemon_sign_close(void)
{
  u3_usig* sig_u;

  for ( sig_u = u3_Host.sig_u; sig_u; sig_u = sig_u->nex_u ) {
    uv_close((uv_handle_t*)&sig_u->sil_u, (uv_close_cb)free);
  }
}
/* _boothack_cb(): setup pier via message as if from client.
*/
void
_boothack_cb(uv_timer_t* tim_u)
{
  _daemon_doom(_boothack_doom());
}

/* _daemon_loop_init(): stuff that comes before the event loop
*/
void
_daemon_loop_init()
{
  //  initialize terminal/logging
  //
  u3_term_log_init();

  //  start signal handlers
  //
  _daemon_sign_init();
  _daemon_sign_move();

  //  async "boothack"
  // /
  uv_timer_start(&u3K.tim_u, _boothack_cb, 0, 0);
}

/* _daemon_loop_exit(): cleanup after event loop
*/
void
_daemon_loop_exit()
{
  unlink(u3K.certs_c);
}

/* u3_king_commence(): start the daemon
*/
void
u3_king_commence()
{
  u3_Host.lup_u = uv_default_loop();

  //  start up a "fast-compile" arvo for internal use only
  //  (with hashboard always disabled)
  //
  sag_w = u3C.wag_w;
  u3C.wag_w |= u3o_hashless;

  u3m_boot_lite();

  //  wire up signal controls
  //
  u3C.sign_hold_f = _daemon_sign_hold;
  u3C.sign_move_f = _daemon_sign_move;

  //  Ignore SIGPIPE signals.
  {
    struct sigaction sig_s = {{0}};
    sigemptyset(&(sig_s.sa_mask));
    sig_s.sa_handler = SIG_IGN;
    sigaction(SIGPIPE, &sig_s, 0);
  }

  //  boot the ivory pill
  //
  {
    u3_noun lit;

    if ( 0 != u3_Host.ops_u.lit_c ) {
      lit = u3m_file(u3_Host.ops_u.lit_c);
    }
    else {
      lit = u3i_bytes(u3_Ivory_pill_len, u3_Ivory_pill);
    }

    if ( c3n == u3v_boot_lite(lit)) {
      u3l_log("lite: boot failed\r\n");
      exit(1);
    }
  }

  //  initialize top-level timer
  //
  uv_timer_init(u3L, &u3K.tim_u);

  //  run the loop
  //
  _daemon_loop_init();
  uv_run(u3L, UV_RUN_DEFAULT);
  _daemon_loop_exit();
}

/* u3_king_bail(): immediately shutdown.
*/
void
u3_king_bail(void)
{
  _daemon_loop_exit();
  u3_pier_bail();
  exit(1);
}

/* u3_king_grab(): gc the daemon
*/
void
u3_king_grab(void* vod_p)
{
  c3_w tot_w = 0;
  FILE* fil_u;

  c3_assert( u3R == &(u3H->rod_u) );

#ifdef U3_MEMORY_LOG
  {
    //  XX date will not match up with that of the worker
    //
    u3_noun wen = u3dc("scot", c3__da, u3k(u3A->now));
    c3_c* wen_c = u3r_string(wen);

    c3_c nam_c[2048];
    snprintf(nam_c, 2048, "%s/.urb/put/mass", u3_pier_stub()->pax_c);

    struct stat st;
    if ( -1 == stat(nam_c, &st) ) {
      mkdir(nam_c, 0700);
    }

    c3_c man_c[2048];
    snprintf(man_c, 2048, "%s/%s-daemon.txt", nam_c, wen_c);

    fil_u = fopen(man_c, "w");
    fprintf(fil_u, "%s\r\n", wen_c);

    c3_free(wen_c);
    u3z(wen);
  }
#else
  {
    fil_u = u3_term_io_hija();
    fprintf(fil_u, "measuring daemon:\r\n");
  }
#endif

  tot_w += u3m_mark(fil_u);
  tot_w += u3_pier_mark(fil_u);

  u3a_print_memory(fil_u, "total marked", tot_w);
  u3a_print_memory(fil_u, "sweep", u3a_sweep());

#ifdef U3_MEMORY_LOG
  {
    fclose(fil_u);
  }
#else
  {
    u3_term_io_loja(0);
  }
#endif
}