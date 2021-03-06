====
eachdo
====

|nimble-version| |nimble-install| |gh-actions|

eachdo executes commands with each multidimensional values.

.. contents:: Table of contents

Usage
=====

.. code-block:: shell

   $ eachdo / echo % / % 1 2 3
   1
   2
   3

   $ eachdo -- / useradd -m -d /home/USER USER / USER hello world foo bar
   $ ls -d /home/*
   /home/hello
   /home/world
   /home/foo
   /home/bar

   $ eachdo -- / echo FIRST LAST / FIRST taro hanako ichiro  / LAST yamada tanaka suzuki
   taro yamada
   hanako tanaka
   ichiro suzuki

   $ eachdo --matrix -- / echo FIRST LAST / FIRST taro hanako ichiro  / LAST yamada tanaka suzuki
   taro yamada
   taro tanaka
   taro suzuki
   hanako yamada
   hanako tanaka
   hanako suzuki
   ichiro yamada
   ichiro tanaka
   ichiro suzuki

Installation
============

.. code-block:: shell

   $ nimble install eachdo

or

Download from `Releases <https://github.com/jiro4989/eachdo/releases>`_

LICENSE
=======

MIT

Development
===========

Release workflow
^^^^^^^^^^^^^^^^

GitHub Action runs when you pushed new tags.

.. code-block:: shell

   $ git tag <new_tag>
   $ git push origin <new_tag>

   or

   $ git push origin --tags

GitHub Action creates a new release and upload your assets.

Release workflows:

|image-release-workflow|

Details, see `release.yml <./.github/workflows/release.yml>`_.

.. |gh-actions| image:: https://github.com/jiro4989/eachdo/workflows/test/badge.svg
   :target: https://github.com/jiro4989/eachdo/actions
.. |nimble-version| image:: https://nimble.directory/ci/badges/eachdo/version.svg
   :target: https://nimble.directory/ci/badges/eachdo/nimdevel/output.html
.. |nimble-install| image:: https://nimble.directory/ci/badges/eachdo/nimdevel/status.svg
   :target: https://nimble.directory/ci/badges/eachdo/nimdevel/output.html

.. |image-release-workflow| image:: https://user-images.githubusercontent.com/13825004/87944618-9897fc00-cada-11ea-9401-74167f04b5c4.png
