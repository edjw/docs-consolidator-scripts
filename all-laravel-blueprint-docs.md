

# advanced-configuration.md

---
title: Advanced Configuration
description: Publish the configuration file to configure Blueprint to follow your own custom conventions.
extends: _layouts.documentation
section: content
---
## Blueprint Configuration {#blueprint-configuration}
Blueprint aims to provide sensible defaults which align nicely with Laravel's conventions. However, you are free to configure Blueprint to follow your own custom conventions.

You may publish the configuration file when running the `blueprint:new` command by passing the `--config` (or `-c`) flag:

```sh
php artisan blueprint:new --config
```

Alternatively, you may publish the configuration file with the following standalone command:

```sh
php artisan vendor:publish --tag=blueprint-config
```

This will copy a `blueprint.php` file into the `config` folder. Similar to the default Laravel configuration files, each of the configuration options are preceded by a detailed comment.

In summary, there are options for customizing the paths and namespaces for generated components, as well as options to toggle code generation. For example, to always generate foreign key constraints or PHPDocs for model properties.

To see all the available options, browse the [`blueprint.php` configuration file on GitHub](https://github.com/laravel-shift/blueprint/blob/master/config/blueprint.php).

---



# available-commands.md

---
title: Blueprint Commands
description: Blueprint comes with a set of artisan commands for generating new components and referencing existing components within your Laravel application.
extends: _layouts.documentation
section: content
---
## Blueprint Commands {#blueprint-commands}
Blueprint comes with a set of `artisan` commands which are helpful during code generation. All of these commands are under the `blueprint` namespace.

While we will cover each of the commands below, you may get additional help for any of these commands by using the `--help` option. For example:

```sh
php artisan blueprint:build --help
```

### Build Command {#build-command}
The `blueprint:build` command is the one you'll use most often as this handles [Generating Components](/docs/generating-components).

It accepts a single argument of path to your _draft_ file. This argument is optional. By default, Blueprint will attempt to load a `draft.yaml` (or `draft.yml`) file from the project root folder.

As such, it's convenient to use the `draft.yaml` file for defining components, but reuse it instead of creating separate _draft_ files each time you run the `blueprint:build` command.

When complete, `blueprint:build` will output a list of the files it created and updated.

### New Command {#new-command}
Blueprint includes a `blueprint:new` command. This command may be helpful when you want to start using Blueprint within your project.

The `blueprint:new` command will generate a `draft.yaml` file with stubs for the `models` and `controllers` sections, as well as run the [`trace` command](#trace-command) to preload your existing models into Blueprint's cache.

^^^
This command has optional flags. `--config` (or `-c`) for also publishing the configuration file, and `--stubs` (or `-s`) for publishing the stub files.
^^^

### Erase Command {#erase-command}
Blueprint also comes with a `blueprint:erase` command. Anytime you run `blueprint:build`, the list of generated components is cached in a local `.blueprint` file.

The `blueprint:erase` command can be used to _undo_ the last `blueprint:build` command. Upon running this command, any of the files generated during the last _build_ will be deleted.

If you realize a mistake after running `blueprint:build` and would like to _rebuild_ your components, your may run `blueprint:erase` and `blueprint:build`.

^^^
While the `blueprint:erase` command is offered for convenience, its capabilities are limited. Instead, Blueprint  recommends running `blueprint:build` from a _clean working state_. This way, you can use version control commands to _undo_ the changes with finer control.
^^^

### Publish Stubs Command {#stubs-command}
Blueprint allows you to publish and modify the stubs. Similiar to Laravel, Blueprint uses these files when generating new components. Blueprint will use any custom stubs, before falling back to the default stubs.

To publish the stubs for customizing, you may run the `blueprint:stubs` command.

### Trace Command {#trace-command}
When using Blueprint with existing applications, you may need to reference existing models when generating new components. Furthermore, even though Blueprint caches the generated model definitions in a `.blueprint` file, this file may become outdated as you continue to develop your application.

At anytime, you may run the `blueprint:trace` command to have Blueprint analyze your application and update its cache with all of your existing models.

---



# contributing.md

---
title: Contributing to Blueprint
description: Contribute to Blueprint by submitting an issue, opening a Pull Request, adding to the docs, or sharing your love of Blueprint on Twitter.
extends: _layouts.documentation
section: content
---
## Contributing to Blueprint {#contributing-to-blueprint}
Contributions may be made by submitting a Pull Request against the `master` branch.

Submitted PRs should:

- Explain the change, ideally using _before_ and _after_ examples.
- Include tests which verify the change.
- Pass all build steps.

You may also contribute by [opening an issue](https://github.com/laravel-shift/blueprint/issues) to report a bug or suggest a new feature. Or submit a Pull Request to improve the [Blueprint Documentation](https://github.com/laravel-shift/blueprint-docs).

If you are so inclined, you may also say "thanks" or proclaim your love of Blueprint [on Twitter](https://twitter.com/gonedark).

---



# controller-shorthands.md

---
title: Controller Shorthands
description: Learn to use syntax shorthands to generate controllers even faster with Blueprint.
extends: _layouts.documentation
section: content
---
## Controller Shorthands {#controller-shorthands}
In addition to some of the statement shorthands and model reference conveniences, Blueprint also offers shorthands for generating [resource](#resource-shorthand) and [invokable](#invokable-shorthand) controllers.

### Resource Shorthand {#resource-shorthand}
This aligns with Laravel‘s preference for creating [resource controllers](https://laravel.com/docs/controllers#resource-controllers).

Instead of having to write out all of the actions and statements common to CRUD behavior within your controllers, you may instead use the `resource` shorthand.

The `resource` shorthand automatically infers the model reference based on the controller name. Blueprint will expand this into the 7 resource actions with the appropriate statements for each action: `index`, `create`, `store`, `show`, `edit`, `update`, and `destroy`.

For example, the following represents the _longhand_ definition of resource controller:

```yaml
controllers:
  Post:
    index:
      query: all:posts
      render: post.index with:posts
    create:
      render: post.create
    store:
      validate: post
      save: post
      flash: post.id
      redirect: post.index
    show:
      render: post.show with:post
    edit:
      render: post.edit with:post
    update:
      validate: post
      update: post
      flash: post.id
      redirect: post.index
    destroy:
      delete: post
      redirect: post.index
```

Instead, you may generate the equivalent by simply writing `resource`.

```yaml
controllers:
  Post:
    resource
```

By default, the `resource` shorthand generates the 7 _web_ resource actions. Of course, you are welcome to set this explicitly as `resource: web`.

Blueprint doesn’t stop there. You may also specify a value of `api`. A value of `api` would generate the 5 resource actions of an API controller with the appropriate statements and responses for each action: `index`, `store`, `show`, `update`, and `destroy`.

You may also specify the exact controller actions you wish to generate by specifying any of the 7 resource actions as a comma separated list. If you wish to use the API actions, prefix the action with `api.`.

The following examples demonstrates which methods would be generated for each of the shorthands.

```yaml
# generate only index and show actions
resource: index, show

# generate only store and update API actions
resource: api.store, api.update

# generate "web" index and API destroy actions
resource: index, api.destroy
```

While you may use this shorthand to generate these controller actions quickly, and update the code after, you may also combine the `resource` shorthand with any additional actions or even override the defaults.

The following example demonstrates the definition for controller which will generate the all 7 resource actions, plus a `download` action, and will use the defined statements for the `show` action instead of the shorthand defaults.

```yaml
controllers:
  Post:
    resource: all
    download:
      find: post.id
      respond: post
    show:
      query: comments where:post.id
      render: post.show with:post,comments
```

### Invokable Shorthand {#invokable-shorthand}
You may also use Blueprint to generate [single action controllers](https://laravel.com/docs/controllers#single-action-controllers),
using the `invokable` shorthand:

```yaml
controllers:
  Report:
    invokable
```

The above draft is equivalent to explicitly defining an `__invoke` action which renders a view with the same name as the controller:

```yaml
controllers:
  Report:
    __invoke:
      render: report
```

For convenience, you may also define an `invokable` action instead of having to remember the underlying `__invoke` syntax:

```yaml
controllers:
  Report:
    invokable:
      fire: ReportGenerated
      render: report
```

All of the above draft files would generate the following route for an invokable controller:

```php
Route::get('/report', App\Http\Controllers\ReportController::class);
```

---



# controller-statements.md

---
title: Controller Statements
description: Blueprint comes with an expressive set of statements to define behavior common within Laravel controllers.
extends: _layouts.documentation
section: content
---
## Controller Statements {#controller-statements}
Blueprint comes with an expressive set of statements which define code within each controller action, but also additional components to generate.

Each statement is a `key: value` pair.

The `key` defines the _type_ of statement to generate. Currently, Blueprint supports the following types of statements: `delete`, `dispatch`, `find`, `fire`, `flash`, `notify`, `query`, `redirect`, `render`, `resource`, `respond`, `save`, `send`, `store`, `update`, `validate`.


#### delete {#delete-statement}
Generates an Eloquent statement for deleting a model. Blueprint uses the controller action to infer which statement to generate.

For example, within a `destroy` controller action, Blueprint will generate a `$model->delete()` statement. Otherwise, a `Model::destroy()` statement will be generated.


#### dispatch {#dispatch-statement}
Generates a statement to dispatch a [Job](https://laravel.com/docs/queues#creating-jobs) using the `value` to instantiate an object and pass any data.

For example:

```yaml
dispatch: SyncMedia with:post
```

If the referenced _job_ class does not exist, Blueprint will create one using any data to define properties and a `__construct` method which assigns them.


#### find {#find-statement}
Generates an Eloquent `find` statement. If the `value` provided is a qualified [reference](#references), Blueprint will expand the reference to determine the model. Otherwise, Blueprint will attempt to use the controller to determine the related model.


#### fire {#fire-statement}
Generates a statement to dispatch a [Event](https://laravel.com/docs/events#defining-events) using the `value` to instantiate the object and pass any data.

For example:

```yaml
fire: NewPost with:post
```

If the referenced _event_ class does not exist, Blueprint will create one using any data to define properties and a `__construct` method which assigns them.


#### flash {#flash-statement}
Generates a statement to [flash data](https://laravel.com/docs/session#flash-data) to the session. Blueprint will use the `value` as the session key and expands the reference as the session value.

For example:

```yaml
flash: post.title
```

#### notify {#notify-statement}
Generates a statement to send a [Notification](https://laravel.com/docs/notifications) using the `value` to instantiate the object, specify the recipient, and pass any data.

For example:

```yaml
notify: post.author ReviewPost with:post
```

If the referenced _notification_ class does not exist, Blueprint will create one using any data to define properties and a `__construct` method which assigns them.

You may also send a notification using the [`Notifiable` trait](https://laravel.com/docs/notifications#using-the-notifiable-trait) by passing a model reference.

For example:

```yaml
notify: user AccountAlert
```


#### query {#query-statement}
Generates an Eloquent query statement using `key:value` pairs provided in `value`. Keys may be any of the basic query builder methods for [`where` clauses](https://laravel.com/docs/queries#where-clauses) and [ordering](https://laravel.com/docs/queries#ordering-grouping-limit-and-offset).

For example:

```yaml
query: where:title where:content order:published_at limit:5
```

Currently, Blueprint supports generating query statements for `all`, `get`, `pluck`, and `count`.


#### redirect {#redirect-statement}
Generates a `return redirect()` statement using the `value` as a reference to a named route passing any data parameters.

For example:

```yaml
redirect: post.show with:post
```


#### render {#render-statement}
Generates a `return view();` statement for the referenced template with any additional view data as a comma separated list.

For example:

```yaml
render: post.show with:post,foo,bar
```

When the template does not exist, Blueprint will generate the Blade template for the view.


#### resource {#resource-statement}
Generates response statement for the [Resource](https://laravel.com/docs/eloquent-resources) to the referenced model. You may prefix the plural model reference with `collection` or `paginate` to return a resource collection or paginated collection, respectively.

If the resource for the referenced model does not exist, Blueprint will create one using the model definition.

For example:

```yaml
resource: user
resource: paginate:users
```


#### respond {#respond-statement}
Generates a response which returns the given value. If the value is an integer, Blueprint will generate the proper `response()` statement using the value as the status code. Otherwise, the value will be used as the name of the variable to return.

For example:

```yaml
respond: post.show with:post
```

When the template does not exist, Blueprint will generate the Blade template for the view.


#### save {#save-statement}
Generates an Eloquent statement for saving a model. Blueprint uses the controller action to infer which statement to generate.

For example, for a `store` controller action, Blueprint will generate a `Model::create()` statement. Otherwise, a `$model->save()` statement will be generated.


#### send {#send-statement}
Generates a statement to send a [Mailable](https://laravel.com/docs/mail#generating-mailables) or [Notification](https://laravel.com/docs/7.x/notifications) using the `value` to instantiate the object, specify the recipient, and pass any data.

For example:

```yaml
send: ReviewPost to:post.author with:post
```

If the referenced _mailable_ class does not exist, Blueprint will create one using any data to define properties and a `__construct` method which assigns them.


#### store {#store-statement}
Generates a statement to [store data](https://laravel.com/docs/session#storing-data) to the session. Blueprint will slugify the `value` as the session key and expands the reference as the session value.

For example:

```yaml
store: post.title
```

Generates:

```php
$request->session()->put('post-title', $post->title);
```


#### update {#update-statement}
Generates an Eloquent `update` statement for a model. You may use a value of the model reference to generate a generic `update` statement, or a comma separated list of column names to update.

For example:

```yaml
update: post
update: title, content, author_id
```

When used with a resource controller, Blueprint will infer the model reference.

#### validate {#validate-statement}
Generates a form request with _rules_ based on the referenced model definition. You may use a value of the model reference to validate all columns, or a comma separated list of the column names to validate.

For example:

```yaml
validate: post
validate: title, content, author_id
```

Blueprint also updates the type-hint of the injected request object, as well as any PHPDoc reference.

---



# defining-controllers.md

---
title: Defining Controllers
description: Learn how to define controllers to generate not only controllers, but events, jobs, mailables, and more with Blueprint.
extends: _layouts.documentation
section: content
---
## Defining Controllers {#defining-controllers}
Similar to [defining models](/docs/defining-models), Blueprint also supports defining _controllers_. You may do so within the `controllers` section, listing controllers by name. For each controller, you may define multiple `actions` which contain a list of _statements_.

Consider the `controllers` section of the following draft file:

```yaml
controllers:
  Post:
    index:
      query: all
      render: post.index with:posts
    create:
      render: post.create
    store:
      validate: title, content
      save: post
      redirect: post.index

  Comment:
    show:
      render: comment.show with:comment
```

From this definition, Blueprint will generate two controllers. A `PostController` with `index`, `create`, and `store` actions. And a `CommentController` with a `show` action.

While you may specify the full name of a controller, Blueprint will automatically suffix controller names with `Controller` to follow Laravel's naming conventions. So, for convenience, you may simply specify the root name of the controller - be it singular or plural.

Blueprint will generate the methods for each controller's actions. In addition, Blueprint will register routes for each action. The HTTP method will be inferred based on the action name. For example, Blueprint will register a `post` route for the `store` action. Otherwise, a `get` route will be registered.

For these reasons, Blueprint recommends defining [resource controllers](/docs/controller-shorthands#resource-shorthand). Doing so allows Blueprint to infer details and generate even more code automatically.

If you wish to namespace a controller, you may prefix the controller name. Blueprint will use this prefix as the namespace and properly save the generated controller class following Laravel conventions. For example, defining an `Api\Post` controller will generate a `App\Http\Controllers\Api\PostController` class saved as `app/Http/Controllers/Api/PostController.php`.

Review the [advanced configuration](/docs/advanced-configuration) to customize these namespaces and paths further.

Finally, Blueprint will analyze each of the statements listed within the action to generate the body of each controller method. For example, the above definition for the `index` action would generate the following controller method:

```php
public function index(Request $request): View
{
    $posts = Post::all();

    return view('post.index', compact('posts'));
}
```

Blueprint has statements for many of the common actions within Laravel. Some statements generate code beyond the controller. Review the [Controller Statements](/docs/controller-statements) section for a full list of statements and the code they generate.

---



# defining-models.md

---
title: Defining Models
description: Learn how to define models to generate not only models, but migrations, factories, and more with Blueprint.
extends: _layouts.documentation
section: content
---
## Defining Models {#defining-models}
Within the `models` section of a draft file you may define multiple models. Each model is defined with a _name_ followed by a list of columns. Columns are `key: value` pairs where `key` is the column name and `value` defines its attributes.

Expanding on the example above, this draft file defines multiple models:

```yaml
models:
  Post:
    title: string:400
    content: longtext
    published_at: nullable timestamp

  Comment:
    content: longtext
    published_at: nullable timestamp

  # additional models...
```

From this definition, Blueprint creates two models: `Post` and `Comment`, respectively. You may continue to define additional models.

Blueprint recommends defining the model name in its _StudlyCase_, singular form to follow Laravel's model naming conventions. For example, use `Post` instead of `post`, `Posts`, or `posts`.

For each of the model columns, the `key` will be used as the exact column name. The _attributes_ are a space separated string of [data types and modifiers](/docs/model-data-types).

For example, using the `Post` definition above, Blueprint would generate the following migration code:

```php
Schema::create('posts', function (Blueprint $table) {
    $table->id();
    $table->string('title', 400);
    $table->longText('content');
    $table->timestamp('published_at')->nullable();
    $table->timestamps();
});
```

---



# extending-blueprint.md

---
title: Extending Blueprint
description: Build your own add-ons to generate even more code or add your own syntax.
extends: _layouts.documentation
section: content
---
## Extending Blueprint {#extending-blueprint}
From the beginning, Blueprint was designed to be extendable. There’s so much more code you could generate from the _draft_ file, as well as add your own syntax.

Blueprint's primary focus will always be models and controllers. However, Blueprint encourages the Laravel community to create additional packages for generating even more components.

For example, generating HTML for CRUD views, or components for [Laravel Nova](https://nova.laravel.com/).

Blueprint is [bound to the container](https://laravel.com/docs/container#binding) as a _singleton_. This means you can resolve an instance of the `Blueprint` object either from within your own application or another Laravel package.

All of the parsing and code generation is managed by this `Blueprint`. As such, you may register your own _lexer_ or _generator_ to generate additional code when `blueprint:build` is run.

By registering a lexer, Blueprint will pass an array of the parsed tokens from the YAML file. With these, you could build your own data structures to add the Blueprints _tree_.

Each registered generator is then called with tree and responsible for generating code. By default, this contains the parsed `models` and `controllers`. However, it may also contain additional items you may have placed in the tree with a lexer.

In addition, I also discuss the architecture for extending Blueprint as well as adding new syntax for [database seeders](/docs/generating-database-seeders) during this [weekly Blueprint live-stream](https://www.youtube.com/watch?v=ZxpmSAXKG1A&t=1656).

### Community Addons
You may use these addons in your projects or as an example of how to create your own and possibly share them with the Laravel community.


- [Laravel Nova](https://github.com/Naoray/blueprint-nova-addon): Automatically generate Nova resources for each of the models specified in your _draft file_.
- [API Resources Tests](https://github.com/axitbv/laravel-blueprint-streamlined-test-addon): Generate test code similar to Blueprint, but using an [opinionated and streamlined](https://github.com/laravel-shift/blueprint/pull/220) style.
- [TALL-forms](https://github.com/tanthammar/tall-blueprint-addon): Automatically generate _TALL_ forms for each of the models specified in your draft file.

### Additional Services
The following services also support using _Blueprint_ by either accepting or generating a draft file.

- [drawSQL](https://drawsql.app/): Generate _draft file_ from your database entity relationship diagrams.

---



# generated-tests.md

---
title: Generated Tests
description: Blueprint generates HTTP tests for any of the controller actions you define.
extends: _layouts.documentation
section: content
---
## Generated Tests {#generated-tests}
For any controller action generated by Blueprint, a corresponding [HTTP Test](https://laravel.com/docs/http-tests) will be generated. Each test will contain _arrange_, _act_, and _assert_ code.

The _arrange_ section will set up any [model factories](https://laravel.com/docs/database-testing#using-factories), as well as [mock](https://laravel.com/docs/mocking) any of the underlying Facades used within the controller action.

Next, the _act_ section will send the appropriate HTTP request to the route with any parameters and request data for the controller action.

Finally, the _assert_ section will verify the response as well as the behavior for any mock.

While these tests are generated to be runnable out of the box, they are provided as a foundation. You should always review them for opportunities to strengthen their assertions and update them as you continue to write more code.

^^^
Blueprint generates PHPUnit tests by default. If you would to generate [Pest](https://pestphp.com/) tests instead, you may edit your [Blueprint config](/docs/advanced-configuration). Under the `generators` option, simply uncomment `\Blueprint\Generators\PestTestGenerator::class` and comment or remove `\Blueprint\Generators\PhpUnitTestGenerator::class`.
^^^

---



# generating-components.md

---
title: Generating Components
description: Learn how to rapidly generate Laravel components using a Blueprint draft file.
extends: _layouts.documentation
section: content
---
## Generating Components {#generating-components}
Blueprint provides `artisan` commands to generate multiple Laravel components from a _draft_ file. The draft file contains a _definition_ using a YAML syntax, with a few _shorthands_ for convenience.

By default, the `blueprint:build` command attempts to load a `draft.yaml` (or `draft.yml`) file. While you are welcome to create multiple _draft_ files, it's common to simply reuse the `draft.yaml` file over and over to generate code for your application.

### Draft file syntax {#draft-file-syntax}
Within the draft file you define _models_ and _controllers_ using an expressive, human-readable YAML syntax.

Let's review the following draft file:

```yaml
models:
  Post:
    title: string:400
    content: longtext
    published_at: nullable timestamp

controllers:
  Post:
    index:
      query: all
      render: post.index with:posts

    store:
      validate: title, content
      save: post
      send: ReviewNotification to:post.author with:post
      dispatch: SyncMedia with:post
      fire: NewPost with:post
      flash: post.title
      redirect: post.index
```

This draft file defines a model named `Post` and a controller with two actions: `index` and `store`. You may, of course, define multiple models and controllers in your own draft files.

At first, this YAML may seem dense. But its syntax aligns nicely with the same syntax you'd use within Laravel. For example, all of the column data types are the same you would use when [creating columns](https://laravel.com/docs/migrations#columns) in a migration.

In addition, the _statements_ within each controller actions use familiar terms like `validate`, `save`, and `fire`.

Blueprint also leverages conventions and uses shorthands whenever possible. For example, you don't need to define the `id`, `created_at`, and `updated_at` columns in your models. Blueprint automatically generates these.

You also don't have to specify the _Controller_ suffix when defining a controller. Blueprint automatically appends it when not present. All of this aligns with Blueprint's goal of _rapid development_.

### Generated code {#generated-code}
From just these 20 lines of YAML, Blueprint will generate all of the following Laravel components:

- A _model_ class for `Post` complete with `fillable`, `casts`, and `dates` properties, as well as relationships methods.
- A _migration_ to create the `posts` table.
- A [_factory_](https://laravel.com/docs/database-testing) intelligently set with fake data.
- A _controller_ class for `PostController` with `index` and `store` actions complete with code generated for each [statement](#statements).
- Resource _routes_ for the `PostController` actions.
- A [_form request_](https://laravel.com/docs/validation#form-request-validation) of `StorePostRequest` validating `title` and `content` based on the `Post` model definition.
- A _mailable_ class for `ReviewNotification` complete with a `post` property set through the _constructor_.
- A _job_ class for `SyncMedia` complete with a `post` property set through the _constructor_.
- An _event_ class for `NewPost` complete with a `post` property set through the _constructor_.
- A _Blade template_ of `post/index.blade.php` rendered by `PostController@index`.
- An [HTTP Test](https://laravel.com/docs/http-tests) complete with respective _arrange_, _act_, and _assert_ sections for the `PostController` actions.

---



# generating-database-seeders.md

---
title: Generating Database Seeders
description: Learn how to define seeders with Blueprint to generate database seeders which leverage the generated model factories.
extends: _layouts.documentation
section: content
---
## Generating Database Seeders {#defining-models}
Blueprint also supports defining a `seeders` section within a draft file to generate [database seeders](https://laravel.com/docs/seeding) for a given model.

The syntax for this section is simply `seeders: value`, where `value` is a comma separated list of [model references](/docs/model-references).

For example:

```yaml
models:
  Post:
    title: string:400
    content: longtext
    published_at: nullable timestamp

  Comment:
    post_id: id
    content: longtext
    user_id: id

  User:
    name: string

seeders: Post, Comment
```

From this definition, Blueprint will create two seeders: `PostSeeder` and `CommentSeeder`, respectively.

Notice Blueprint does not create a `UserSeeder`  in this instance since it was not included in the list of model references.

The code within the generated seeder uses the [model factories](https://laravel.com/docs/database-testing#writing-factories) to seed the database with 5 records.

For example, within the `PostSeeder`, Blueprint would generate the following code:

```php
public function run(): void
{
    factory(\App\Post::class, 5)->create();
}
```

---



# getting-started.md

---
title: Getting Started
description: Getting started with Jigsaw's docs starter template is as easy as 1, 2, 3.
extends: _layouts.documentation
section: content
---
## Getting Started {#getting-started}
_Blueprint_ is an open-source tool for **rapidly generating multiple** Laravel components from a **single, human readable** definition.

Blueprint has two driving principles:

1. Increase development speed
2. Promote Laravel conventions

### Requirements {#requirements}
Blueprint requires a Laravel application running version 6.0 or higher.

While Blueprint may be more flexible in a future version, it currently assumes a standard project structure using the default `App` namespace.

---



# installation.md

---
title: Installing Blueprint
description: Add Blueprint to your Laravel application with Composer and setup your project in under 2 minutes.
extends: _layouts.documentation
section: content
---
## Installing Blueprint {#installing-blueprint}
You may install Blueprint via Composer. It's recommended to install Blueprint as a development dependency of your Laravel application. If you haven't created a Laravel application yet, follow the [installation guide in the Laravel docs](https://laravel.com/docs/10.x/installation#creating-a-laravel-project).

When ready, run the following command to install Blueprint:

```sh
composer require -W --dev laravel-shift/blueprint
```

### Additional Packages {#additional-packages}
Blueprint also _suggests_ installing the [Laravel Test Assertions package](https://github.com/jasonmccreary/laravel-test-assertions), as the generated tests may use some of the additional, helpful assertions provided by this package.

You may do so with the following command:

```sh
composer require --dev jasonmccreary/laravel-test-assertions
```

### Ignoring Blueprint files {#ignoring-blueprint-files}
You may also consider ignoring files Blueprint uses from version control. We'll talk about these files more in [Generating Components](/docs/generating-components). But for now, these files are mainly used as a "scratch pad" or "local cache". So it's unlikely you'd want to track their changes.

You may quickly add these files to your `.gitignore` with the following command:

```sh
echo '/draft.yaml' >> .gitignore
echo '/.blueprint' >> .gitignore
```

---



# keys-and-indexes.md

---
title: Model Keys and Indexes
description: Blueprint supports keys and indexes on your models through the column definition and by leveraging convention.
extends: _layouts.documentation
section: content
---
## Model Keys and Indexes {#model-keys-indexes}
Blueprint supports keys and indexes on your models through the column definition and by leveraging convention.

Within the column definition, you may specify a key or index using the `id` column type or the `foreign`, `index`, or `unique` column modifiers.

The simplest of these are the `index` and `unique` modifiers. Blueprint will generate the necessary code to the migration to add the _index_. In turn, Laravel will create an index for this column.

The `foreign` column modifier will also generate the necessary code to create an index on the column. In addition, it will generate code to add the reference and cascade "on delete" constraints.

By default, Blueprint will automatically infer the foreign reference from the column name just as Laravel does. For example, a column name of `user_id`, would imply a reference to the `id` column of the `users` table.

If you are not following Laravel's naming conventions, you may set the attribute on the `foreign` modifier. Blueprint supports either the foreign table name or the table and column name using dot notation.

For example, all of the following column definitions generate a foreign reference to the `id` column of the `users` table.

```yaml
    user_id: id foreign
    owner_id: id foreign:users
    uid: id foreign:users.id
```

Finally, while the `id` column type does not create an explicit index on the database, it does imply a foreign key relationships for the model.

Similar to the `foreign` column modifier, you may specify an attribute on the `id` column type. In this case, you specify the foreign model name or the model and column name using dot notation.

^^^
Blueprint will always create model relationships for `id` and `uuid` columns. So it is only necessary to specify `foreign` when you want to generate constraints. If you always want to generate foreign key constraints, you should enable at the `use_constraints` [configuration option](/docs/advanced-configuration).
^^^


### Composite Indexes {#composite-indexes}
Blueprint also supports adding a composite index. You may do so adding the `indexes` key to your model definition. This key accepts an array of key/value pairs, where the key is the type of index and the value is a comma separated list of column names.

For example, this will add a unique composite index on the `owner_id` and the `badge_number` column of the `users` table.

```yaml
  User:
    indexes:
      - unique: owner_id, badge_number
```

---



# model-data-types.md

---
title: Model Data Types
description: Blueprint supports all of the column types within Laravel, as well as a few shorthands for defining models.
extends: _layouts.documentation
section: content
---
## Model Data Types {#model-data-types}
Blueprint supports all of the [available column types](https://laravel.com/docs/migrations#creating-columns) within Laravel. Blueprint also has a built-in column type of `id`. This is one of the [model shorthands](/docs/model-shorthands).

Some of these column types support additional attributes. For example, the `string` column type accepts a length, `decimal` accepts a _precision_ and _scale_, and an `enum` may accept a list of values.

Within Blueprint, you may define these attributes by appending the column type with a colon (`:`) followed by the attribute value. For example:

```yaml
payment_token: string:40
total: decimal:8,2
status: enum:pending,successful,failed
```

You may also specify _modifiers_ for each column. Blueprint supports most of the [column modifiers](https://laravel.com/docs/migrations#column-modifiers) available in Laravel, including: `autoIncrement`, `always`, `charset`, `collation`, `comment`, `default`, `foreign`, `index`, `nullable`, `onDelete`, `onUpdate`, `primary`, `unsigned`, `unique`, `useCurrent`, and `useCurrentOnUpdate`.

^^^
To give you full control, Blueprint uses the literal value you define for the `default` modifier. For example, defining an _integer_ with `default:1`, versus a _string_ with `default:'1'`.
^^^

Similar to the column type attributes, the `foreign` modifier also supports attributes. This is discussed in [Keys and Indexes](/docs/keys-and-indexes).

The column type and modifiers are separated by a space. While you may specify these in any order, it's recommend to specify the column type first, then the modifiers. For example:

```yaml
email: string:100 nullable index
```

^^^
When specifying an attribute or modifier value which contains a space, you must wrap the value in double quotes (`"`). For example, `enum:Ordered,Completed,"On Hold"`. Blueprint will _unwrap_ the value during parsing.
^^^

---



# model-references.md

---
title: Model References
description: Learn how to leverage Blueprint to infer model references or specify your own.
extends: _layouts.documentation
section: content
---
## Model References {#model-references}
For convenience, Blueprint will use the name of a controller to infer the related model. For example, Blueprint will assume a `PostController` relates to a `Post` model.

Blueprint also supports a dot (`.`) syntax for more complex references. This allows you to define values which reference columns on other models.

For example, to _find_ a `User` model within the `PostController` you may use:

```yaml
controllers:
  Post:
    show:
      find: user.id
      # ...
```

While these references will often be used within _Eloquent_ and `query` statements, they may be used in other statements as well. When necessary, Blueprint will convert these into variable references using an arrow (`->`) syntax.

Many times within a controller you will be referencing a model. Blueprint attempts to infer the context based on the controller name.

However, there may be some statements where you need to reference additional models. You may do this by specifying the name of the model. This may be a model that you are generating in the current draft file or an existing model within your application.

You should reference these models using their class name. For example, `User`. If you have namespaced the model, you should prefix it with the appropriate namespace relative to the model namespace. For example, `Admin\User`.

If you wish to also reference an attribute of a model for one of the statements, you may specify it using dot notation. For example, `User.name`.

Let’s consider the following draft file:

```yaml
controllers:
  Post:
    index:
      query: all
      render: post.index with:posts
    create:
      find: user.id
      render: post.create with:user
    store:
      validate: title, published_at
      save: post
      redirect: post.show
    show:
      query: all:comments
      render: post.show with:post,comments

```

Based on the model name, Blueprint will use the model `Post` for any context that doesn’t reference a model by name.

In this case, the `validate` statement will use `title`, `published_at` on the `Post` model.

The `index` action will query all _posts_. However, the `show` action will query all _comments_. And the `create` action will find the `User` model by the `id` attribute.

---



# model-relationships.md

---
title: Model Relationships
description: Blueprint also allows you to define many of the relationships available within Laravel.
extends: _layouts.documentation
section: content
---
## Model Relationships {#model-relationships}
Blueprint also allows you to define many of the relationships available within Laravel, including: `belongsTo`, `hasOne`, `hasMany`, and `belongsToMany`.

^^^
While you may define the `belongsTo` relationship explicitly, it is not necessary. Simply defining a column with the `id` data type or `foreign` attribute is enough for Blueprint to automatically generate the relationship.
^^^

To define one of these relationships, you may add a `relationships` section to your model definition. Within this section, you specify the relationship type followed by a comma separated list of model names.

For example, the following definition adds some common relationships to a `Post` model:

```yaml
models:
  Post:
    title: string:400
    published_at: timestamp nullable
    relationships:
      hasMany: Comment
      belongsToMany: Media, Site
      belongsTo: \Spatie\LaravelPermission\Models\Role
```

^^^
While you may specify the `relationships` anywhere within the model section, Blueprint recommends doing so at the bottom.
^^^

For each of these relationships, Blueprint will add the respective [Eloquent relationship](https://laravel.com/docs/eloquent-relationships) method within the generated model class. In addition, Blueprint will automatically generate the "pivot table" migration for any `belongsToMany` relationship.

^^^
When defining relationships or [foreign keys](/docs/keys-and-indexes) the referenced tables must exist. While Blueprint makes an effort to generate migrations for "pivot tables" last, it is still possible to encounter errors. If so, you may define your models without these relationships or constraints and add them manually later.
^^^

To specify a model which is not part of your application, you may provide the fully qualified class name. Be sure to include the initial `\` (backslash). For example, `\Spatie\LaravelPermission\Models\Role`.

You may also _alias_ any of the relationships to give them a different name by suffixing the model name by appending the model name with a colon (`:`) followed by the name. For example:

```yaml
models:
  Post:
    relationships:
      hasMany: Comment:reply
```

Blueprint will automatically pluralize the alias correctly based on the relationship type. In the case of a `belongsToMany` relationship, an alias will also be used as the pivot table name.

Sometimes you may want to use an [intermediate model](https://laravel.com/docs/eloquent-relationships#defining-custom-intermediate-table-models) for a `belongsToMany` relationship. If so, you may prefix the alias with an ampersand (`&`) and reference the model name. For example:

```yaml
User:
  relationships:
    belongsToMany: Team:&Membership
```

---



# model-shorthands.md

---
title: Model Shorthands
description: Learn to use syntax shorthands to generate models even faster with Blueprint.
extends: _layouts.documentation
section: content
---
## Model Shorthands {#model-shorthands}
Blueprint provides several _shorthands_ when defining models. While using these may at time appear as invalid YAML, they are provided for developer convenience. Blueprint will properly expand these shorthands into valid YAML before parsing the draft file.

Blueprint provides an implicit model shorthand by automatically generating the `id` and _timestamp_ (`created_at`, and `updated_at`) columns on every model. You never need to specify these columns when defining models.

Of course, you are able to define these yourself at anytime. For example, if you want to use a different column type for the _id_ column, like `uuid`.

You may also disable them by marking them as `false`. For example, to disable the _timestamp_ columns, you may add `timestamps: false` to your model definition. If you wish to generate the _timestamp_ columns with timezone column types, you may use the `timestampsTz` shorthand.

Blueprint also offers a `softDeletes` shorthand. Adding this to your model definition will generate the appropriate `deleted_at` column, as well add the `SoftDeletes` trait to your model. Similarly, if you want timezone information, you may use the `softDeletesTz` shorthand.

You may write these shorthands using the camel casing shown above or all lowercase. Blueprint supports both for developer convenience.

To illustrate using these shorthands, here is the _longhand_ definition of a model:

```yaml
models:
  Widget:
    id: id
    deleted_at: timestamp
    created_at: timestamp
    updated_at: timestamp
```

And again using shorthands:

```yaml
models:
  Widget:
    id
    softDeletes
    timestamps
```

And finally, leveraging the full power of Blueprint by also using implicit model shorthands:

```yaml
models:
  Widget:
    softDeletes
```

---



# videos.md

---
title: Videos
description: A list of video demonstrations, tutorials, and deep-dives on Blueprint.
extends: _layouts.documentation
section: content
---
## Blueprint Videos {#blueprint-videos}
Below are a list of videos which demonstrate using Blueprint.

- [Quick Demo](https://www.youtube.com/watch?v=A_gUCwni_6c) on YouTube
- [Rapid Code Generation With Blueprint](https://laracasts.com/series/guest-spotlight/episodes/9) on Laracasts
- [Create Models with Blueprint](https://laracasts.com/series/rapid-laravel-development-with-filament/episodes/1) on Laracasts
- Weekly live-streams of [Building Blueprint](https://www.youtube.com/playlist?list=PLmwAMIdrAmK5q0c0JUqzW3u9tb0AqW95w) on YouTube

---

