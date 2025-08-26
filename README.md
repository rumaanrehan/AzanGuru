# AzanGuru

Compiled on Flutter Version 3.16.4

# Flutter BLoC Pattern Application

This is a Flutter application that use BLoC (Business Logic Component) pattern for state management. The BLoC pattern helps in separating the presentation layer from the business logic, making the code more modular and easier to test.

## Getting Started

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Table of Contents

- [Features](#features)
- [Installation](#installation)
- [Project Structure](#project-structure)
- [Usage](#usage)
- [Contributing](#contributing)
- [License](#license)

## Features

- Modular architecture using BLoC pattern
- State management with reactive programming
- Clean separation of UI and business logic
- Easy to extend and maintain

## Installation

1. **Clone the repository**:

   ```bash
   git clone git@bitbucket.org:eia2023/azan-guru-mobile.git
   cd azan-guru-mobile
   ```

2. **Install dependencies**:

   ```bash
   flutter pub get
   ```

3. **Run the application**:
   ```bash
   flutter run
   ```

## Project Structure

```
flutter_bloc_app/
│
├── lib/
│ ├── bloc/
│ │ └── example_bloc/
│ │   └── example_bloc.dart
│ │   └── example_event.dart
│ │   └── example_state.dart
│ ├── common/
│ │ └── contains common UI
│ ├── constant/
│ │ └── app_assets.dart
│ │ └── app_colors.dart
│ │ └── enums.dart
│ ├── ui/
│ │ └── example_screen.dart
│ ├── main.dart
│
└── README.md
```

### Explanation of the Structure

- **bloc/**: Contains the BLoC classes which handle business logic and state management.
- **events/**: Contains the event classes which represent actions that can be performed.
- **states/**: Contains the state classes which represent the different states of the application.
- **models/**: Contains the data models used in the application.
- **repositories/**: Contains repository classes which handle data fetching and manipulation.
- **screens/**: Contains the UI screens of the application.
- **widgets/**: Contains reusable widgets used across the application.
- **main.dart**: The entry point of the application.

## Usage

1. **Define an Event**:

   ```dart
   // example_event.dart
   abstract class ExampleEvent {}

   class LoadExampleData extends ExampleEvent {}
   ```

2. **Define a State**:

   ```dart
   // example_state.dart
   abstract class ExampleState {}

   class ExampleInitial extends ExampleState {}

   class ExampleLoading extends ExampleState {}

   class ExampleLoaded extends ExampleState {
     final List<ExampleModel> data;
     ExampleLoaded(this.data);
   }

   class ExampleError extends ExampleState {
     final String message;
     ExampleError(this.message);
   }
   ```

3. **Create a BLoC**:

   ```dart
   // example_bloc.dart
   class ExampleBloc extends Bloc<ExampleEvent, ExampleState> {
     final ExampleRepository repository;

     ExampleBloc(this.repository) : super(ExampleInitial());

     @override
     Stream<ExampleState> mapEventToState(ExampleEvent event) async* {
       if (event is LoadExampleData) {
         emit(ExampleLoading());
         try {
           final data = await repository.fetchData();
           emit(ExampleLoaded(data));
         } catch (e) {
           emit(ExampleError(e.toString()));
         }
       }
     }
   }
   ```

4. **Use BLoC in the UI**:
   ```dart
   // example_screen.dart
   class ExampleScreen extends StatelessWidget {
     @override
     Widget build(BuildContext context) {
       return BlocProvider(
         create: (context) => ExampleBloc(ExampleRepository()),
         child: Scaffold(
           appBar: AppBar(
             title: Text('Example BLoC App'),
           ),
           body: BlocBuilder<ExampleBloc, ExampleState>(
             builder: (context, state) {
               if (state is ExampleInitial) {
                 return Center(child: Text('Press the button to load data'));
               } else if (state is ExampleLoading) {
                 return Center(child: CircularProgressIndicator());
               } else if (state is ExampleLoaded) {
                 return ListView.builder(
                   itemCount: state.data.length,
                   itemBuilder: (context, index) {
                     return ListTile(
                       title: Text(state.data[index].name),
                     );
                   },
                 );
               } else if (state is ExampleError) {
                 return Center(child: Text('Error: ${state.message}'));
               }
               return Container();
             },
           ),
           floatingActionButton: FloatingActionButton(
             onPressed: () {
               context.read<ExampleBloc>().add(LoadExampleData());
             },
             child: Icon(Icons.download),
           ),
         ),
       );
     }
   }
   ```
