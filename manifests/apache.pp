class gitlab::apache() inherits gitlab::params {

  include apache::mod::proxy_balancer

  apache::balancer { 'unicornservers':
    proxy_set => { 'timeout' => 30 },
  }
  apache::balancermember { 'node0':
    balancer_cluster => 'unicornservers',
    url              => 'http://127.0.0.1:8080',
  }
  apache::vhost { 'gitlab.local':
    port     => 80,
    docroot  => '/var/www/gitlab',
    rewrites => [
      {
        comment      => 'redirect all non-static content',
        rewrite_cond => ['%{DOCUMENT_ROOT}/%{REQUEST_FILENAME} !-f'],
        rewrite_rule => ['^/(.*)$ balancer://unicornservers%{REQUEST_URI} [P,QSA,L]'],
      },
    ],
    proxy_pass => [
      { path   => '/',
        url    => 'balancer://unicornservers/',
      },
    ]
  }
}
