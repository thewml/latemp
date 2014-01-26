use ExtUtils::MakeMaker;
WriteMakefile(
              NAME	   => 'Bundle::Latemp',
              VERSION_FROM => 'Latemp.pm',
              'dist'       => {
                               COMPRESS => 'gzip -9f',
                               SUFFIX   => '.gz',
                               DIST_DEFAULT => 'all tardist',
                              },
             );

